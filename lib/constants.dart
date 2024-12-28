const String baseUrl = "https://google.com/";
const String customErrorPage = '''
    <!DOCTYPE html>
    <html>
      <head>
        <title>Error</title>
        <style>

         @font-face {
      font-family: 'vazir';

      src: url('data:font/ttf;base64,BASE64_ENCODED_FONT_HERE') format('truetype');
    }

          body {
            font-family: vazir;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f8f9fa;
          }
          .error-container {
             font-family: vazir;
            text-align: center;
          }
          .error-container h1 {
            font-family: vazir;
            font-size: 48px;
            color: #dc3545;
          }
          .error-container p {
            font-family: vazir;
            font-size: 40px;
            color: #6c757d;
          }
          .retry-button {
             font-family: vazir;
            padding: 16px 80px;
            margin-top: 20px;
            border: 1px solid #00382E;
            border-image-slice: 1;
            background-color: #084D41;
            color: #E5FFE5;
            background-image: linear-gradient(180deg, rgba(255, 255, 255, 0.3) 0%, rgba(255, 255, 255, 0) 100%);
            font-size: 40px;
            border-radius: 10px;
          }
        </style>
      </head>
      <body>
        <div class="error-container">
        <img src="data:image/png;base64,BASE64_ENCODED_IMAGE_HERE" alt="Local Image" width="220" />
          <p>!خطایی رخ داد</p>
          <button class="retry-button" onclick="window.flutter_inappwebview.callHandler('testFuncArgs', 1)">تلاش مجدد</button>
        </div>
      </body>
    </html>
  ''';
