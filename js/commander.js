const commander = require("commander");
const program = new commander.Command();
const something = program.parse(process.argv);

let lib;

function parse() {
  return something;
}

function args() {
  return something.args;
}

lib = {
  args,
  parse
};

module.exports = lib;
