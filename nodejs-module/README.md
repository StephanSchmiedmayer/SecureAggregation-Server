# Secure Aggregation Module

Secure aggregation module in Node.js

## Usage
### Client Side:
```js
const { SAClient } = require('secure-aggregation');

new SAClient({
    host: 'localhost',
    port: '8080'
});
```
### Server Side:
```js
const { SAServer } = require('secure-aggregation');

new SAServer({
    host: 'localhost',
    port: '8080'
});
```

# Examples
### Starting the example server
```bash
node examples/server.example.js
```

### Starting example clients
```bash
node examples/client.example.js
```

# Based on
* https://github.com/ammartahir24/SecureAggregation
* [Practical Secure Aggregation for Privacy-Preserving Machine Learning](https://eprint.iacr.org/2017/281.pdf)
