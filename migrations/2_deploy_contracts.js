const Land = artifacts.require("landRegistry");

module.exports = function(deployer) {
  deployer.deploy(Land);
};
