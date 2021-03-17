const Link = artifacts.require("Link");
const Dex = artifacts.require("Dex");
const truffleAssert = require('truffle-assertions');
contract("Dex", accounts => {
    it("should only be possible for owner to send the tokens", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await truffleAssert.passes(
            dex.addToken(web3.utils.fromUtf8(link.symbol()), link.address, { from: accounts[0] })
        );
        await truffleAssert.reverts(
            dex.addToken(web3.utils.fromUtf8(link.symbol()), link.address, { from: accounts[1] })
        );
    })

    it("should handle deposit correctly", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await link.approve(dex.address,500);
        await dex.Deposit(web3.utils.fromUtf8(link.symbol()),100);
        let balance=await dex.balances(accounts[0],web3.utils.fromUtf8(link.symbol()));
        assert.equal(balance.toNumber(),100);
    })
    
})