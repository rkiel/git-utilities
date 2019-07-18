const _ = require("lodash");

const path = x => require("../" + x);
const immutable = path("js/immutable");
const shell = path("js/shell");

let lib;

function setCurrentBranch(dp) {
  const cmd = "git rev-parse --abbrev-ref HEAD";

  return shell.capture(cmd).then(x => immutable.set(dp, "branch.current", x));
}

lib = {
  setCurrentBranch
};

module.exports = lib;
