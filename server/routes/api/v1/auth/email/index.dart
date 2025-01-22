import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final String? token = context.request.uri.queryParameters['token'];

  if (token == '123') {
    return Response(
      body: '''
        <head>
          <style type="text/css">
            .message {
              color: green;
              font-size: 24px;
              font-weight: bold;
              text-align: center;
              margin-top: 50px;
              animation: fade-in 2s ease-in-out;
            }

            @keyframes fade-in {
              0% {
                opacity: 0;
              }
              100% {
                opacity: 1;
              }
            }

            .impressive {
              font-size: 48px;
              font-weight: bold;
              color: purple;
              text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
              text-align: center;
              margin-top: 100px;
              animation: rotate 4s linear infinite;
            }

            @keyframes rotate {
              0% {
                transform: rotate(0deg);
              }
              100% {
                transform: rotate(360deg);
              }
            }
          </style>
        </head>
        <body>
          <div class="message">
            <p>The token is valid!</p>
          </div>
          <div class="impressive">
            <p>Impressive!</p>
          </div>
        </body>
      ''',
      headers: {'Content-Type': 'text/html'},
    );
  }
  return Response(
    body: '<h1>Token is invalid</h1>',
    headers: {'Content-Type': 'text/html'},
    statusCode: 401,
  );
}
