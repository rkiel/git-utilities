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

function toPromise(dp) {
  return Promise.resolve(dp);
}

function echo(dp) {
  console.log(JSON.stringify(dp, null, 2));
  return dp;
}

function start() {
  return toPromise(parse());
}

lib = {
  args,
  parse,
  featureName,
  prefix,
  start,
  echo
};

module.exports = lib;
