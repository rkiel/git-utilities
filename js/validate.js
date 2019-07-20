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

function mustBeFeatureBranch(dp) {
  const parts = dp.branch.parts;
  if (
    parts.length > 2 &&
    commander.prefix() === parts[0] &&
    branch.isStandard(parts[1])
  ) {
    return dp;
  } else {
    throw `ERROR: ${dp.branch.current} is not a feature branch`;
  }
}

lib = {
  currentIsStandardBranch,
  mustBeFeatureBranch,
  featureIsNotStandardBranch
};

module.exports = lib;
