let lib;

function standard() {
  return ["master", "release"];
}

function isStandard(b) {
  return lib.standard().includes(b);
}

function isNonStandard(b) {
  return !lib.isStandard(b);
}

lib = { standard, isStandard, isNonStandard };

module.exports = lib;
