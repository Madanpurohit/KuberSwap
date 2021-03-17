const Dex=artifacts.require('Dex');
const Link=artifacts.require("Link");
const truffleAssert=require('truffle-assertions');
contract("Dex",accounts=>{
    it("should throw a error if eth balance is  too low when creating buy order ",async()=>{
        let dex=await Dex.deployed();
        let link=await Link.deployed();
        await truffleAssert.reverts(
            dex.createLimitOrder(0,web3.utils.fromUtf8(link.symbol()),10,1)
        );
        dex.depositEth({value:10});
        await truffleAssert.passes(
            dex.createLimitOrder(0,web3.utils.fromUtf8(link.symbol()),10,1) 
        );
    });
    it("should throw a error if token balance is  too low when creating buy order ",async()=>{
        let dex=await Dex.deployed();
        let link=await Link.deployed();
        await truffleAssert.reverts(
            dex.createLimitOrder(1,web3.utils.fromUtf8(link.symbol()),10,1)
        );
        await link.approve(dex.address,500);
        await dex.addToken(web3.utils.fromUtf8(link.symbol()),link.address,{from:accounts[0]});
        await dex.Deposit(web3.utils.fromUtf8(link.symbol()),10);
        await truffleAssert.passes(
            dex.createLimitOrder(1,web3.utils.fromUtf8(link.symbol()),10,1) 
        );
    });

    it("The buy order book should be ordered from high to low starting at index 0 ",async()=>{
        let dex=await Dex.deployed();
        let link=await Link.deployed();
        await link.approve(dex.address,500);
        await dex.depositEth({value:3000});
        await dex.createLimitOrder(0,web3.utils.fromUtf8(link.symbol()),1,300);
        await dex.createLimitOrder(0,web3.utils.fromUtf8(link.symbol()),1,100);
        await dex.createLimitOrder(0,web3.utils.fromUtf8(link.symbol()),1,200);
        let orderBook=await dex.getOrderBook(web3.utils.fromUtf8(link.symbol()),0);
        //console.log(orderBook);
        assert(orderBook.length>0);
        for(let i=0;i<orderBook.length-1;i++){
            assert(orderBook[i].price>=orderBook[i+1].price,"not right order in buy book");
        }

    });

    it("The sell order book should be ordered from low to high starting at index 0 ",async()=>{
        let dex=await Dex.deployed();
        let link=await Link.deployed();
        await link.approve(dex.address,500);
        await dex.depositEth({value:3000});
        await dex.createLimitOrder(1,web3.utils.fromUtf8(link.symbol()),1,300);
        await dex.createLimitOrder(1,web3.utils.fromUtf8(link.symbol()),1,100);
        await dex.createLimitOrder(1,web3.utils.fromUtf8(link.symbol()),1,200);
        let orderBook=await dex.getOrderBook(web3.utils.fromUtf8(link.symbol()),1);
        assert(orderBook.length>0)
        //console.log(orderBook);
        for(let i=0;i<orderBook.length-1;i++){
            assert(orderBook[i].price<=orderBook[i+1].price,"not right order in sell book");
        }

    });


})