// Make stacker-globals/lib files globally available to all plugins via require('module')

// Only allow for one stacker-globals in the path to ensure there's only one copy of each lib
if (!process.env.NODE_PATH || process.env.NODE_PATH.indexOf('stacker-globals') < 0) {
  var path = require('path');
  process.env.NODE_PATH = path.resolve(__dirname, './lib') + path.delimiter + process.env.NODE_PATH;
  require('module').Module._initPaths();  // Hack
}

module.exports = {
  _: require('stacker/_'),
  config: require('stacker/config'),
  log: require('stacker/log'),
  promise: require('stacker/promise'),
  utils: require('stacker/utils')
};
