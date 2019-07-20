const _ = require("lodash");

const path = x => require("../" + x);
const commander = path("js/commander");
const immutable = path("js/immutable");
const shell = path("js/shell");
const file = path("js/file");
const branch = path("js/branch");

let lib;

function setBranch(dp, field, branch) {
  return immutable.set(dp, `branch.${field}`, branch);
}

function setCurrentBranch(dp) {
  return file
    .read(".git/HEAD")
    .then(contents => contents.split("/"))
    .then(parts => _.last(parts))
    .then(last => last.trim())
    .then(branch => immutable.set(dp, "branch.current", branch));
}

function setStandardAndFeature(dp) {
  const current = _.get(dp, "branch.current");
  if (branch.isStandard(current)) {
    return immutable.set(
      immutable.set(dp, "branch.standard", current),
      "branch.feature",
      false
    );
  } else {
    const parts = current.split("-");
    if (
      parts.length > 2 &&
      commander.prefix() === parts[0] &&
      branch.isStandard(parts[1])
    ) {
      return immutable.set(
        immutable.set(dp, "branch.standard", parts[1]),
        "branch.feature",
        current
      );
    } else {
      return immutable.set(
        immutable.set(dp, "branch.standard", false),
        "branch.feature",
        false
      );
    }
  }
}

function setRemote(dp) {
  const current = _.get(dp, "branch.current");
  if (branch.isStandard(current)) {
    return immutable.set(dp, "branch.remote", false);
  } else {
    return file
      .exists(`.git/refs/remotes/origin/${current}`)
      .then(() => immutable.set(dp, "branch.remote", current))
      .catch(() => immutable.set(dp, "branch.remote", false));
  }
}

function gather(dp) {
  return file
    .exists(".git")
    .then(() => ({}))
    .then(lib.setCurrentBranch)
    .then(lib.setStandardAndFeature)
    .then(lib.setRemote)
    .catch(() => {
      throw "not in GIT_ROOT";
    });
}

// function setCurrentBranch(dp) {
//   const cmd = "git rev-parse --abbrev-ref HEAD";
//
//   return shell.capture(cmd).then(x => immutable.set(dp, "branch.current", x));
// }

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
  //setCurrentBranch,
  setFeatureBranch,
  setStandardBranch,
  parseCurrentBranch,
  isBranchRemote,
  gather,
  setStandardAndFeature,
  setCurrentBranch,
  setRemote,
  setBranch: _.curry(setBranch)
};

module.exports = lib;
