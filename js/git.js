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

function parseCurrentBranch(dp) {
  const parts = dp.branch.current.split("-");
  return immutable.set(dp, "branch.parts", parts);
}

function setStandardBranch(dp) {
  const parts = _.get(dp, "branch.parts", []);
  return immutable.set(dp, "branch.standard", parts[1]);
}

function isBranchRemote(dp) {
  const branch = _.get(dp, "branch.current");
  const cmd = `git branch -r|grep origin|grep -v 'HEAD'|grep ${branch}`;
  return shell
    .capture(cmd)
    .then(x => x.trim())
    .then(x =>
      x === ""
        ? immutable.set(dp, "branch.remote", false)
        : immutable.set(dp, "branch.remote", branch)
    );
}

lib = {
  setCurrentBranch,
  setFeatureBranch,
  setStandardBranch,
  parseCurrentBranch,
  isBranchRemote
};

module.exports = lib;
