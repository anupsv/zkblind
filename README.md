# zkblind

## How to run

1. Run the installs as in the zkemail directories and compile the contracts along with generating the keys

### Terminal 1
1.  Run a python web server to serve the keys. It needs CORS enabled for the webapp to work.
2. Something like this: 
```
#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler, test
import sys

class CORSRequestHandler (SimpleHTTPRequestHandler):
    def end_headers (self):
        self.send_header('Access-Control-Allow-Origin', '*')
        SimpleHTTPRequestHandler.end_headers(self)

if __name__ == '__main__':
    test(CORSRequestHandler, HTTPServer, port=int(sys.argv[1]) if len(sys.argv) > 1 else 8000)
```

### Terminal 2

1. Run webapp by going to the directory `cd packages/app`
2. Run `yarn start`
3. Open the specified url on the browser