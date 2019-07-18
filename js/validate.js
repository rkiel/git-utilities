const path = x => require("../" + x);
const branch = path("js/branch");
const commander = path("js/commander");

let lib;

function currentIsStandardBranch(dp) {
  if (branch.isNonStandard(dp.branch.current)) {
    const branches = branch
      .standard()
      .sort()
      .join(", ");
    throw `ERROR: starting branch must be one of: ${branches}`;
  } else {
    return dp;
  }
}

function featureIsNotStandardBranch(dp) {
  if (branch.isStandard(commander.featureName())) {
    const branches = branch
      .standard()
      .sort()
      .join(", ");
    throw `ERROR: feature branch cannot be any of: ${branches}`;
  } else {
    return dp;
  }
}

lib = { currentIsStandardBranch, featureIsNotStandardBranch };

module.exports = lib;
