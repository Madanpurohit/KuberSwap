const Link = artifacts.require("Link");
const Wallet=artifacts.require("Wallet");

module.exports = async function (deployer,network,accounts) {
  await deployer.deploy(Link);
  let wallet=await Wallet.deployed();
  let link=await Link.deployed();
  await link.approve(wallet.address,500);
  await wallet.addToken(web3.utils.fromUtf8(link.symbol()),link.address);
  await wallet.Deposit(web3.utils.fromUtf8(link.symbol()),100);
  let balance=await wallet.balances(accounts[0],web3.utils.fromUtf8(link.symbol()));
  console.log("balance is :",balance);
};
