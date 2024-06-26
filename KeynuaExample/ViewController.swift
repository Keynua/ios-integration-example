//
//  ViewController.swift
//  KeynuaExample
//
//  Created by willy on 19/06/24.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var buttonOpenWebView: UIButton!
    var idLabel: UILabel!
    var statusLabel: UILabel!
    
    /**
     * TODO: Change Keynua URL according to the current environment
     * PROD: https://sign.keynua.com
     * STG: https://sign.stg.keynua.com
     */
    let KEYNUA_URL = "https://sign.stg.keynua.com"
    
    // TODO: Change this eventURL with your customURL APP
    let EVENT_URL = "keynuaapp://com.keynua.webviewexample"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupWebView()
        requestCameraAndMicrophonePermissions()
        
        // Workaround to ask for internet permissions before opening the webview
        let connection = NWConnection(host: NWEndpoint.Host("www.apple.com"), port: NWEndpoint.Port(80), using: .tcp)
        connection.start(queue: .main)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        idLabel = UILabel()
        idLabel.text = "ID: Pending"
        idLabel.textAlignment = .center
        idLabel.textColor = .black
        idLabel.font = UIFont.systemFont(ofSize: 16)
        idLabel.frame = CGRect(x: 20, y: 200, width: view.frame.size.width - 40, height: 20)

        statusLabel = UILabel()
        statusLabel.text = "Status: Pending"
        statusLabel.textAlignment = .center
        statusLabel.textColor = .black
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.frame = CGRect(x: 20, y: 230, width: view.frame.size.width - 40, height: 20)

        buttonOpenWebView = UIButton(type: .system)
        buttonOpenWebView.setTitle("Abrir WebView", for: .normal)
        buttonOpenWebView.backgroundColor = UIColor.blue
        buttonOpenWebView.setTitleColor(UIColor.white, for: .normal)
        buttonOpenWebView.layer.cornerRadius = 10
        buttonOpenWebView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(idLabel)
        view.addSubview(statusLabel)
        view.addSubview(buttonOpenWebView)
        
        NSLayoutConstraint.activate([
            buttonOpenWebView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonOpenWebView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonOpenWebView.widthAnchor.constraint(equalToConstant: 200),
            buttonOpenWebView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        buttonOpenWebView.addTarget(self, action: #selector(openWebView), for: .touchUpInside)
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .video
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.isHidden = true
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc func openWebView() {
        webView.isHidden = false
        idLabel.isHidden = true
        statusLabel.isHidden = true
        buttonOpenWebView.isHidden = true
        // TODO: Replace this Token with a valid token
        let token = "USER-TOKEN-HERE"

        if var urlComponents = URLComponents(string: KEYNUA_URL) {
            urlComponents.queryItems = [
                URLQueryItem(name: "token", value: token),
                URLQueryItem(name: "eventURL", value: EVENT_URL)
            ]

            if let url = urlComponents.url {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        /**
         * Validate that the URL is the same as the one sent in EventURL
         */
        if url.absoluteString.starts(with: EVENT_URL) {
            closeWebView()
            let queryParams = extractQueryParams(url: url)
            queryParams.forEach { key, value in
                print("WebViewURLParams", "\(key): \(value)")
            }

            // If it's an Identification, it will return "identificationId". If it's a Contract, it will return "contractId"
            idLabel.text = "ID: \(queryParams["identificationId"] ?? queryParams["contractId"] ?? "")"
            statusLabel.text = "Status: \(queryParams["status"] ?? "")"
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func closeWebView() {
        webView.isHidden = true
        idLabel.isHidden = false
        statusLabel.isHidden = false
        buttonOpenWebView.isHidden = false
    }
    
    private func requestCameraAndMicrophonePermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                DispatchQueue.main.async {
                    self.showAlert(message: "Camera permission not granted.")
                }
            }
        }
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                DispatchQueue.main.async {
                    self.showAlert(message: "Microphone permission not granted.")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Permission Required", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func extractQueryParams(url: URL) -> [String: String] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
            return [:]
        }
        var params = [String: String]()
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
    
    func getQueryParam(queryParams: [String: String], key1: String, key2: String) -> String? {
        return queryParams[key1] ?? queryParams[key2]
    }
    
}
