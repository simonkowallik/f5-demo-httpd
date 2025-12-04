# F5 Demo HTTPD

A lightweight, customizable demo web application built on NGINX. Designed for testing load balancers, reverse proxies, and demonstrating traffic distribution across multiple backend instances.

## Features

- **Visual Instance Identification** - Each container displays a unique color, making it easy to identify which backend is serving requests
- **Multi-Protocol Support** - HTTP, HTTPS, and HTTP/2 with auto-generated self-signed certificates
- **Multiple Response Formats** - HTML, JSON, and plain text endpoints
- **Request Introspection** - View all request headers, client/server IPs, and connection details
- **Lightweight** - Based on NGINX alpine for minimal footprint
- **Latency Monitoring** - Built-in ping functionality to measure response times

## Quick Start

### Using Docker Compose

```bash
docker compose up -d
```

The application will be available at:
- HTTP: http://localhost:80
- HTTPS: https://localhost:443

### Using Docker Run

```bash
docker run -d -p 80:80 -p 443:443 ghcr.io/OWNER/f5-demo-httpd:latest
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `F5DEMO_NODENAME` | Display name for the instance | Container hostname |
| `F5DEMO_COLOR` | Background color for HTTP (hex without #) | Random from palette |
| `F5DEMO_COLOR_SSL` | Background color for HTTPS (hex without #) | Random from palette |

### Docker Compose Environment

Copy the example environment file and customize:

```bash
cp dot-env-example .env
```

Example `.env` file:
```
ADDRESS=0.0.0.0
HTTP_PORT=80
HTTPS_PORT=443
F5DEMO_NODENAME=my-server
F5DEMO_COLOR=f59744
F5DEMO_COLOR_SSL=dccbc7
```

### Custom Configuration via Docker Compose

```yaml
services:
  f5-demo-nginx:
    image: ghcr.io/OWNER/f5-demo-httpd:latest
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      - F5DEMO_NODENAME=pool-member-one
      - F5DEMO_COLOR=a0bf37
      - F5DEMO_COLOR_SSL=37a0bf
```

## API Endpoints

### `GET /` or `GET /index.html`
Interactive HTML dashboard displaying server information with live ping monitoring.

### `GET /json`
Returns server information in JSON format.

```bash
curl http://localhost/json
```

```json
{
  "node_name": "my-server",
  "hostname": "abc123def",
  "server_ip": "172.17.0.2",
  "server_port": "80",
  "client_ip": "172.17.0.1",
  "client_port": "54321",
  "scheme": "HTTP",
  "color": "#f59744",
  "request_method": "GET",
  "request_uri": "/json",
  "request_headers": {
    "Host": "localhost",
    "User-Agent": "curl/8.0.0"
  }
}
```

### `GET /text`
Returns server information in plain text format with ASCII art banner.

```bash
curl http://localhost/text
```

### `GET /ping`
Lightweight health check endpoint for latency measurements.

```bash
curl http://localhost/ping
```

```json
{
  "pong": true,
  "timestamp": 1701705600000,
  "node_name": "my-server",
  "hostname": "abc123def"
}
```

## SSL/TLS Certificates

The container automatically generates self-signed certificates on first startup:

- RSA certificate at `/etc/nginx/ssl/cert.pem` and `/etc/nginx/ssl/key.pem`
- ECDSA certificate at `/etc/nginx/ssl/eccert.pem` and `/etc/nginx/ssl/eckey.pem`
- DH parameters at `/etc/nginx/ssl/dhparam.pem`

To use custom certificates, mount them to the container:

```yaml
volumes:
  - ./my-cert.pem:/etc/nginx/ssl/cert.pem:ro
  - ./my-key.pem:/etc/nginx/ssl/key.pem:ro
```

## Building from Source

```bash
# Build the image
docker build -t f5-demo-httpd .

# Run locally
docker run -d -p 80:80 -p 443:443 f5-demo-httpd
```

## Use Cases

- **Load Balancer Testing** - Visually verify traffic distribution with unique colors per backend
- **Reverse Proxy Configuration** - Inspect headers added/modified by upstream proxies
- **HTTP/2 Testing** - Verify HTTP/2 connectivity and protocol negotiation
- **Health Check Validation** - Use `/ping` endpoint for health monitoring
- **Demo Environments** - Showcase multi-tier application architectures

## Color Palettes

### HTTP Colors (vibrant)
- `#f59744` (orange)
- `#c465ff` (purple)
- `#ce5004` (red-orange)
- `#f3dd6d` (yellow)
- `#8568c9` (violet)
- `#ff4caf` (pink)

### HTTPS Colors (soft pastels)
- `#dccbc7` (soft neutral)
- `#d0d7db` (light blue-gray)
- `#f4f4f4` (pale neutral)
- `#88ccc5` (aqua pastel)
- `#92c1e9` (light blue)
- `#addc91` (light green)

## Easter Egg 🎮

See if you can find it.

## License

See [LICENSE.md](LICENSE.md) for license information.
