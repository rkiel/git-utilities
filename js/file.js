const fs = require("fs");
const util = require("util");

let lib;

function exists(path) {
  const stat = util.promisify(fs.stat);
  return stat(path);
}

function read(path) {
  const readFile = util.promisify(fs.readFile);
  return readFile(path).then(buffer => buffer.toString("utf-8"));
}

lib = { exists, read };
module.exports = lib;
