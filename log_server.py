#!/usr/bin/env python

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
import sys
import socket

class LogServer(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()

    def do_GET(self):
        self._set_headers()

        sys.stderr.write(self.path)

    def do_POST(self):
        self._set_headers()
        
        content_len = int(self.headers.getheader('content-length', 0))
        post_body = self.rfile.read(content_len)

        sys.stderr.write(post_body)

    def log_message(self, format, *args):
        return
        
def run(server_class=HTTPServer, handler_class=LogServer, port=80):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Started server on %s' % socket.gethostbyname(socket.gethostname())
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()