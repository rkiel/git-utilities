let lib;

// TODO:  read from .git-utilities
function standard() {
  return ["master", "release", "main", "develop"];
}

function isStandard(b) {
  return lib.standard().includes(b);
}

function isNonStandard(b) {
  return !lib.isStandard(b);
}

lib = { standard, isStandard, isNonStandard };

module.exports = lib;
