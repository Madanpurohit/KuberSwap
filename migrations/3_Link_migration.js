const Migrations = artifacts.require("Link");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
