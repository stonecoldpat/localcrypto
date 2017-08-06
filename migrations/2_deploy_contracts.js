var LocalCrypto = artifacts.require("./LocalCrypto.sol");

module.exports = function(deployer) {
  deployer.deploy(LocalCrypto);
};
