# Integración de Keynua en iOS (Swift)

En el siguiente gráfico, se puede observar el ciclo básico de integración.

![Flow](https://kpublic.s3.amazonaws.com/images/keynua/mobileIntegrationFlow.jpg)

## Descripción

Este repositorio contiene una aplicación de ejemplo en Swift para iOS. La aplicación muestra cómo integrar el flujo de firma o identificación de Keynua usando un WebView. Diseñada para enseñar la implementación efectiva del flujo de autenticación de Keynua en una aplicación iOS.

## Características

- **Permisos de la aplicación**: Antes de inicializar el WebView, la aplicación configura y solicita los permisos necesarios para el uso de la cámara y el micrófono.

- **Integración de WebView**: La aplicación implementa la carga y manejo del flujo de Keynua dentro de un WebView. Es importante agregar `allowsInlineMediaPlayback` en la configuración del WebView para permitir la reproducción de videos directamente en la página; de lo contrario, los videos se mostrarán en negro.

- **Detección de eventos**: La aplicación identifica los eventos del flujo de validación en el WebView. Para detectarlos, la URL cargada debe contener una URL personalizada que servirá como callback. El detalle de cada tipo está en [Tipos de Eventos](#tipos-de-eventos).

- **Identificador de dispositivo (recomendado)**: Puedes enviar el parámetro `deviceId` con un identificador **estable** del dispositivo. Keynua lo usa para reconocer un dispositivo recurrente (antifraude / velocidad) — **nunca** como prueba de fraude por sí solo. Es especialmente importante en WKWebView: su almacenamiento (localStorage, IndexedDB) puede borrarse o recrearse entre sesiones, y con él se pierde el identificador que el widget genera por su cuenta; un id nativo persiste fuera del WebView y sobrevive ese borrado, por lo que se convierte en el anclaje más fuerte. En iOS se recomienda `UIDevice.current.identifierForVendor` (estable por vendor+dispositivo; solo se reinicia cuando se desinstalan todas tus apps del dispositivo).

  ```swift
  if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
      queryItems.append(URLQueryItem(name: "deviceId", value: deviceId))
  }
  ```

  Ejemplo de URL: `https://sign.keynua.com/index.html?token=eyJ0...Qis&deviceId=E621E1F8-C36C-495A-93FC-0C247A3E6E5F`

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

## Tipos de Eventos

Para recibir los eventos del flujo de firma o identificación en tu aplicación, debes definir una URL personalizada para cada tipo de evento descrito a continuación. Utilizaremos esta URL como callback para cada evento, enviando la información correspondiente como parámetros en la consulta (`query param`). Tu aplicación podrá detectar la URL, extraer la información y procesarla según sea necesario.

Esta aplicación de ejemplo solo envía `eventURL` y cierra el WebView cuando la navegación empieza por ese esquema. Con esa configuración, el primer log también cierra el flujo. Para separar el fin del flujo de los logs y los errores, envía `eventDoneURL`, `eventErrorURL` y `eventLogURL`.

### **Detección de Finalización del Flujo**

Debe enviarse el atributo `eventDoneURL`. Si se detecta una URL en este parámetro, se añadirá un botón **"Finalizar"** al concluir la validación. Al presionar este botón, la aplicación ejecutará la URL contenida en el parámetro, agregando los siguientes valores como parte de la consulta:

- `status`: En este evento, el valor siempre será **done**.
- `identificationId`: ID de la identificación. Se enviará solo si es una identificación.
- `contractId`: ID del contrato. Se enviará solo si es un contrato.

El widget no redirige solo al terminar bien. El usuario tiene que presionar el botón.

#### **Ejemplo de URL**

Si deseas redirigir a `myapp://com.company.example` al finalizar el flujo, la URL del WebView debe estructurarse de la siguiente manera:

```
https://sign.keynua.com/index.html?token=eyJ0...Qis&eventDoneURL=myapp://com.company.example
```

### **Detección de Errores en el Flujo**

Debe enviarse el atributo `eventErrorURL`. Si se detecta una URL en este parámetro, el widget navega a ella sin botón cuando el contrato está vencido, eliminado o en máximo de intentos, o cuando un ítem vuelve con error.

- `status`: En este evento, el valor siempre será **error**.
- `errCode`: Código de error que permite determinar cómo reaccionar. La lista de errores se encuentra en la sección ["Errores por tipo de ítem"](https://keynua.github.io/slate/#errores-por-tipo-de-item) de la documentación.
- `errMsg`: Descripción del error recibido.
- `errItemId` (opcional): ID del ítem con error. Este es un valor único del contrato o identificación. Más información en la sección [Propiedades de un ítem](https://keynua.github.io/slate/#propiedades-de-un-item).
- `errItemType` (opcional): Tipo de ítem asociado al error. Más información en [Tipos de ítem](https://keynua.github.io/slate/#tipos-de-item).

#### **Ejemplo de URL**

Si deseas enviar la información de error a `myapp://com.company.example`, la URL del WebView debe estructurarse de la siguiente manera:

```
https://sign.keynua.com/index.html?token=eyJ0...Qis&eventErrorURL=myapp://com.company.example
```

### **Detección de Logs del Flujo**

Debe enviarse el atributo `eventLogURL`. Si se proporciona este parámetro, se enviarán logs del flujo de validación en tiempo real, lo que permitirá monitorear en qué estado se encuentra el usuario dentro del proceso.

Cada log navega a esta URL con `window.location.replace`. La aplicación tiene que interceptar el esquema propio y cancelar la navegación. Si no lo hace, el WebView sale del widget. No uses la misma URL del botón **"Finalizar"**.

- **`status`**: En este evento, el valor siempre será **info**.
- **`funnelId`**: Hace referencia al paso actual en el que se encuentra el usuario. Puede tener los siguientes valores:

  - **`3DLibraryDownloadStarted`**: Comenzó la descarga de la librería 3D.
  - **`3DLibraryDownloadError`**: Ocurrió un error al descargar la librería 3D.
  - **`3DLibraryDownloadFinished`**: Finalizó la descarga de la librería 3D.
  - **`-1:__processdata`**: La información ha comenzado a enviarse para su procesamiento.
  - **`-1:Nothingmore`**: La información se ha enviado correctamente y el usuario está a la espera de que el proceso termine.
  - **`-1:Finished`**: El flujo ha finalizado correctamente.

  Si el `funnelId` hace referencia a un paso dentro del flujo de firma o identificación, tendrá el siguiente formato:
  _`${funnelOrder}:${groupId}:${itemTitle}`_.

  **Ejemplo**:
  _`"2:verificantes-1:Aceptación de Términos"`_, donde:

  - **`funnelOrder`**: Orden del ítem dentro del contrato. Usualmente, el ítem de "Términos y Condiciones" tiene el menor valor, ya que es el primero que se muestra.
  - **`groupId`**: ID del grupo en el que se encuentra el usuario. Si el `funnelId` hace referencia a un ítem sin grupo, este valor no se enviará.
  - **`itemTitle`**: Título del ítem.

- **`action`**: Indica la acción realizada. Puede tener los siguientes valores:
  - **`render-view`**: Cuando la vista se ha mostrado.
  - **`input-value-changed`**: Cuando el usuario ha finalizado la acción en la vista actual. Por ejemplo, aceptó los Términos y Condiciones o finalizó el paso de la Prueba de Vida 3D.
  - **`3d-started`**: Indica que el usuario ha comenzado el flujo de Prueba de Vida 3D y/o validación del Documento de Identidad 3D.
  - **`3d-finished`**: Indica que el flujo de Prueba de Vida 3D y/o validación del Documento de Identidad 3D ha finalizado. Si ha ocurrido un error en el flujo, recibirás el detalle en el [Evento de Error](#detección-de-errores-en-el-flujo).
  - **`otp-view`**: Cuando se muestra la vista para ingresar el código OTP.
  - **`otp-send`**: Cuando se solicita el envío del código OTP.
  - **`otp-verify`**: Cuando el usuario envía el código OTP para verificarlo.

#### **Ejemplo de URL**

Si deseas enviar la información de los logs a `myapp://com.company.example`, la URL del WebView debe estructurarse de la siguiente manera:

```
https://sign.keynua.com/index.html?token=eyJ0...Qis&eventLogURL=myapp://com.company.example
```

### **URL de respaldo**

El atributo `eventURL` se usa cuando falta la URL específica de un evento. Si no envías `eventDoneURL`, el botón **"Finalizar"** abre `eventURL`. Si no envías `eventErrorURL`, los errores se envían a `eventURL`. Si no envías `eventLogURL`, los logs se envían a `eventURL`.

Si solo envías `eventURL`, el primer log del flujo también navega a esa URL. Conviene enviar por separado los atributos de [finalización](#detección-de-finalización-del-flujo), [errores](#detección-de-errores-en-el-flujo) y [logs](#detección-de-logs-del-flujo).

#### **Ejemplo de URL**

```
https://sign.keynua.com/index.html?token=eyJ0...Qis&eventURL=myapp://com.company.example
```

## Cámara del documento

Estos parámetros ajustan la cámara con la que el usuario fotografía el documento de identidad en el flujo Spark. No cambian la prueba de vida ni la cámara frontal.

Son opcionales. Si no envías ninguno, la cámara queda como siempre: enfoca una sola vez al abrirse, pide un ancho de 1280 px y el recuadro ocupa todo el visor.

Se agregan a la misma URL del WebView, con `URLQueryItem`, igual que `deviceId`. Un valor que no cumpla las reglas de abajo se ignora y se usa el valor por defecto de ese parámetro. Los demás parámetros válidos sí se aplican.

### `docFocusMode`

Controla cuándo enfoca la cámara trasera.

- **`single-shot`** (valor por defecto). Al abrir, la cámara enfoca una vez lo que tiene delante y deja el foco fijo. Si el usuario acerca el documento después, no vuelve a enfocar hasta que toca el recuadro.
- **`continuous`**. La cámara sigue enfocando mientras el usuario mueve el documento. Es el modo de la app de cámara del teléfono.

Cualquier otro texto se ignora y se mantiene `single-shot`.

### `docResolutions`

Anchos de la cámara en horizontal, en píxeles, separados por coma. El primero es el que se pide. Los siguientes solo se intentan si el navegador rechaza el anterior. No es una lista de la que el teléfono elige la mejor: con un valor aceptado, se queda con el modo más cercano a ese ancho.

Valores permitidos: `800`, `1024`, `1280`, `1920` y `2560`. Máximo 3. Un número que no esté en la lista se descarta. Si después de descartar no queda ninguno, se usa la lista por defecto.

Sin este parámetro se pide `1280` y, si esa petición falla, `1024` y después `800`.

En un teléfono en vertical el video llega rotado. Pedir `1920` suele entregar unos 1080×1920, no una imagen de 1920 px de ancho. `2560` pide más detalle y aumenta la memoria que usa la detección automática del documento.

Para la mayoría de los casos, `1920` es el valor recomendado.

### `docFrameCoverage`

Fracción del visor que debe ocupar el documento. Va de `0.7` a `1`.

- **`1`** (valor por defecto). El recuadro es todo el visor. El documento hay que acercarlo hasta llenar la cámara.
- Un valor menor, por ejemplo **`0.85`**, deja un marco interior. El documento puede sostenerse más lejos, pero la foto usa menos píxeles. Conviene acompañarlo de un `docResolutions` más alto.

Si el número es menor que `0.7`, se usa `0.7`. Si es mayor que `1`, se usa `1`. Si no es un número, se ignora y se mantiene `1`.

### Ejemplo

```swift
queryItems.append(URLQueryItem(name: "docFocusMode", value: "continuous"))
queryItems.append(URLQueryItem(name: "docResolutions", value: "1920"))
```

Ejemplo de URL: `https://sign.keynua.com/index.html?token=eyJ0...Qis&docFocusMode=continuous&docResolutions=1920`

## Contacto

Para consultas, puedes contactarnos a operaciones@keynua.com
