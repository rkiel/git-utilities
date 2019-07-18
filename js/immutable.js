const _ = require("lodash");

let lib;

function set(dp, path, value) {
  return _.set(_.assign({}, dp), path, value);
}

lib = {
  set
};

module.exports = lib;
