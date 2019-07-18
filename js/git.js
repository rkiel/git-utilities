const _ = require("lodash");

const path = x => require("../" + x);
const commander = path("js/commander");
const immutable = path("js/immutable");
const shell = path("js/shell");

let lib;

function setCurrentBranch(dp) {
  const cmd = "git rev-parse --abbrev-ref HEAD";

  return shell.capture(cmd).then(x => immutable.set(dp, "branch.current", x));
}

function setFeatureBranch(dp) {
  const fb = [
    commander.prefix(),
    dp.branch.current,
    commander.featureName()
  ].join("-");
  return immutable.set(dp, "branch.feature", fb);
}

lib = {
  setCurrentBranch,
  setFeatureBranch
};

module.exports = lib;
