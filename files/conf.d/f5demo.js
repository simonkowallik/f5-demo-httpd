function getServerInfo(r) {
    // Determine scheme - check for HTTP/2 first
    var f5demo_scheme = r.variables.f5demo_scheme || 'UNKNOWN';
    if (r.variables.http2) {
        f5demo_scheme = 'HTTP2';
    }

    return {
        node_name: r.variables.f5demo_nodename || '',
        hostname: r.variables.hostname || '',
        server_ip: r.variables.server_addr || '',
        server_port: r.variables.server_port || '',
        client_ip: r.remoteAddress || '',
        client_port: r.variables.remote_port || '',
        scheme: f5demo_scheme,
        color: r.variables.f5demo_color || '',
        request_method: r.variables.request_method || '',
        request_uri: r.variables.request_uri || '',
        request_headers: getHeadersDict(r.headersIn)
    };
}

function getHeadersDict(headers) {
    var result = {};
    for (var h in headers) {
        result[h] = headers[h];
    }
    return result;
}

function f5demo_json(r) {
    r.headersOut['Content-Type'] = 'application/json';
    r.return(200, JSON.stringify(getServerInfo(r), null, 2) + '\n');
}

function f5demo_text(r) {
    var info = getServerInfo(r);
    var output = `================================================
 ___ ___   ___                    _
| __| __| |   \\ ___ _ __  ___    /_\\  _ __ _ __
| _||__ \\ | |) / -_) '  \\/ _ \\  / _ \\| '_ \\ '_ \\
|_| |___/ |___/\\___|_|_|_\\___/ /_/ \\_\\ .__/ .__/
                                      |_|  |_|
================================================

      Node Name: ${info.node_name}
       Hostname: ${info.hostname}
          Color: ${info.color}

      Server IP: ${info.server_ip}
    Server Port: ${info.server_port}

      Client IP: ${info.client_ip}
    Client Port: ${info.client_port}

         Scheme: ${info.scheme}
 Request Method: ${info.request_method}
    Request URI: ${info.request_uri}

Request Headers:
`;
    for (var h in info.request_headers) {
        output += h.padStart(15) + ': ' + info.request_headers[h] + '\n';
    }

    r.headersOut['Content-Type'] = 'text/plain';
    r.return(200, output);
}



function f5demo_ping(r) {
    r.headersOut['Content-Type'] = 'application/json';
    r.headersOut['Cache-Control'] = 'no-cache, no-store, must-revalidate';
    r.return(200, JSON.stringify({
        pong: true,
        timestamp: Date.now(),
        node_name: r.variables.f5demo_nodename || '',
        hostname: r.variables.hostname || ''
    }) + '\n');
}



export default { f5demo_json, f5demo_text, f5demo_ping };
