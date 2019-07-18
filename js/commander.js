const commander = require("commander");
const program = new commander.Command();
const something = program.parse(process.argv);

let lib;

function args() {
  return something.args;
}

function featureName() {
  return args().join("-");
}

function parse() {
  return { program: something };
}

function prefix() {
  return process.env.FEATURE_USER || process.env.USER;
}

lib = {
  args,
  parse,
  featureName,
  prefix
};

module.exports = lib;
