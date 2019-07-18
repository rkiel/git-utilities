const branch = path("js/branch");

let lib;

function validateCurrentBranch(dp) {
  if (branch.isNonStandard(dp.branch.current)) {
    throw `invalid base branch: ${dp.branch.current}`;
  } else {
    return dp;
  }
}

function validateFeatureName(dp) {
  if (branch.isStandard(commander.featureName())) {
    throw `invalid feature branch: ${commander.featureName()}`;
  } else {
    return dp;
  }
}

lib = { validateCurrentBranch, validateFeatureName };

module.exports = lib;
