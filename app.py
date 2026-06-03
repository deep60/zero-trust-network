import http.server
import json
from datetime import datetime

class ZeroTrustHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {
            "message": "Zero Trust Protected App",
            "time": str(datetime.now()),
            "your_ip": self.client_address[0],
            "security_layers_passed": [
                "Layer 1: Cloudflare Access - Identity verified",
                "Layer 2: VPC - Private subnet",
                "Layer 3: Nginx - Reverse proxy"
            ],
            "status": "All Zero Trust checks passed!"
        }
        self.wfile.write(json.dumps(response, indent=2).encode())

    def log_message(self, format, *args):
        pass

if __name__ == '__main__':
    server = http.server.HTTPServer(('0.0.0.0', 8080), ZeroTrustHandler)
    print("Zero Trust App running on port 8080")
    server.serve_forever()
