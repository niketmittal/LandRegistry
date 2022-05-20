const Migrations = artifacts.require("Migrations");
const 


module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
