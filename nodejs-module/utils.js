const _ = require('lodash/core');

function setDefaults(options, defaults){
    return _.defaults({}, _.clone(options), defaults);
}

/**
 * @param value upper end (not included).
 * @returns a random integer between 0 and (value - 1) parameter
 */
function randrange(value) {
    return Math.floor(Math.random() * value);
}

module.exports.setDefaults = setDefaults;
module.exports.randrange = randrange;
