const utils = require('../utils');

class SecureAggregator {
    constructor(base, mod, dimensions, weights) {
        this.secretkey = utils.randrange(mod);
        this.base = base;
        this.mod = mod;

        this.pubkey = Math.pow(this.base, this.secretkey) % this.mod
        this.sndkey = utils.randrange(mod);
        this.dim = dimensions
        this.weights = weights
        this.keys = {}
        this.id = ''
    }
}

exports = module.exports = SecureAggregator;
