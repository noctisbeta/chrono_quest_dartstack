import 'package:dart_frog/dart_frog.dart';

Middleware securityMiddleware() =>
    (Handler handler) => (RequestContext context) async {
      // Handle CORS preflight requests
      if (context.request.method == HttpMethod.options) {
        return Response(headers: _corsHeaders);
      }

      // Get the response from the handler
      final Response response = await handler(context);

      // Apply security headers to the response
      return response.copyWith(
        headers: {...response.headers, ..._securityHeaders, ..._corsHeaders},
      );
    };

const _securityHeaders = {
  // HSTS - Force HTTPS
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
  // Prevent MIME type sniffing
  'X-Content-Type-Options': 'nosniff',
  // Prevent clickjacking
  'X-Frame-Options': 'DENY',
  // Enable browser XSS filter
  'X-XSS-Protection': '1; mode=block',
  // CSP - Control allowed resources
  'Content-Security-Policy':
      "default-src 'self'; "
      "script-src 'self' 'unsafe-inline' 'unsafe-eval'; "
      "style-src 'self' 'unsafe-inline'; "
      "img-src 'self' data: https:; "
      "connect-src 'self' ws: wss: http: https:",
  'Referrer-Policy': 'strict-origin-when-cross-origin',
};

const _corsHeaders = {
  'Access-Control-Allow-Origin': 'http://localhost:50699',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS, HEAD',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Credentials': 'true',
};
