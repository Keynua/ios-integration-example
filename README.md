# Integración de Keynua en iOS (Swift)

En el siguiente gráfico, se puede observar el ciclo básico de integración.

![Flow](https://kpublic.s3.amazonaws.com/images/keynua/mobileIntegrationFlow.jpg)

## Descripción

Este repositorio contiene una aplicación de ejemplo en Swift para iOS. La aplicación muestra cómo integrar el flujo de firma o identificación de Keynua usando un WebView. Diseñada para enseñar la implementación efectiva del flujo de autenticación de Keynua en una aplicación iOS.

## Características

- **Permisos de la aplicación**: Antes de inicializar el WebView, la aplicación configura y solicita los permisos necesarios para el uso de la cámara y el micrófono.

- **Integración de WebView**: La aplicación implementa la carga y manejo del flujo de Keynua dentro de un WebView. Es importante agregar `allowsInlineMediaPlayback` en la configuración del WebView para permitir la reproducción de videos directamente en la página; de lo contrario, los videos se mostrarán en negro.

- **Detección de Finalización del Flujo**: La aplicación identifica la finalización del flujo de validación en el WebView. Para ello, deben enviar una URL personalizada como valor del parámetro `eventURL` en la URL de firma. Si se detecta la presencia de `eventURL`, se añadirá un botón "Finalizar" al concluir la validación. Al presionar el botón "Finalizar", la aplicación ejecuta la URL contenida en `eventURL`, añadiendo los siguientes parámetros como parte de la consulta:
  - `identificationId`: ID de la identificación.
  - `contractId`: ID del contrato.
  - `status`: Estado de la validación, actualmente solo se soporta el estado "done".

## Pre-requisitos

- Xcode 11 o superior.
- Acceso a internet para cargar el flujo de Keynua.

## Configuración e Instalación

1. Clona este repositorio.
2. Abre el proyecto en Xcode.
3. Modifica el valor del Token de usuario en la aplicación
4. Asegúrate de que las dependencias estén correctamente configuradas.
5. Ejecuta la aplicación en un simulador o dispositivo iOS.

## Uso

1. Inicia la aplicación y accede al WebView.
2. El flujo de Keynua se iniciará automáticamente.
3. Finaliza el proceso en el WebView.
4. Observa cómo la aplicación responde al final del flujo.

## Contacto

Para consultas, puedes contactarnos a operaciones@keynua.com
