var Migrations = artifacts.require("./Migrations.sol");
var LocalCrypto = artifacts.require("./LocalCrypto.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(LocalCrypto);
};
