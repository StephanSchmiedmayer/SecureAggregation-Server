const utils = require('../utils');
const io = require("socket.io-client");
const SecureAggregator = require("./secureAggregator");
const { Matrix } = require('ml-matrix');

class SAClient {
    /**
     * Creates a new client.
     *
     * @param settings Settings about the client
     * @param settings.host Host url
     * @param settings.port Port on which to connect
     * @return {Function}
     * @api public
     */
    constructor(settings = {}) {
        const defaults = {
            host: 'localhost',
            port: '8080'
        };
        settings = utils.setDefaults(settings, defaults);

        console.log("Initialising the Client");
        this.socket = io(`http://${settings.host}:${settings.port}`);

        this.aggregator = new SecureAggregator(3,100103,[10,10], Matrix.ones(10, 10).fill(3.0));
    }
}

exports = module.exports = SAClient;
