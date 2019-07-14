const _ = require("lodash");

let lib;

function set(dp, path, value) {
  return _.assign({}, dp, _.set({}, path, value));
}

lib = {
  set
};

module.exports = lib;
