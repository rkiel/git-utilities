const _ = require("lodash");
const util = require("util");
const child_process = require("child_process");
const exec = util.promisify(child_process.exec);

let lib;

function run(cmd) {
  return exec(cmd);
}

function capture(cmd) {
  return lib.run(cmd).then(x => x.stdout.trim());
}

function _something(dp) {
  return function() {
    return dp;
  };
}

function something(cmd, dp) {
  return lib.run(cmd).then(lib._something(dp));
}

lib = {
  _something,
  run,
  capture,
  something: _.curry(something)
};

module.exports = lib;
