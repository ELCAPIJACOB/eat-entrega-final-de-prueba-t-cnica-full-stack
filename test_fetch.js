const http = require('http');

const data = JSON.stringify({ email: 'maria@nexgen.com', password: 'Usuario1234!' });

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/login',
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'Content-Length': data.length },
};

const req = http.request(options, (res) => {
  let body = '';
  res.on('data', (d) => { body += d; });
  res.on('end', () => {
    const token = JSON.parse(body).data.token;
    
    const req2 = http.request({
      hostname: 'localhost',
      port: 3000,
      path: '/api/usuario/incidencias/1',
      method: 'GET',
      headers: { 'Authorization': 'Bearer ' + token }
    }, (res2) => {
      let body2 = '';
      res2.on('data', (d) => { body2 += d; });
      res2.on('end', () => {
        console.log(JSON.stringify(JSON.parse(body2).data, null, 2));
      });
    });
    req2.end();
  });
});
req.write(data);
req.end();
