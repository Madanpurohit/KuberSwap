pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;
import './Wallet.sol';
contract Dex is Wallet{
    enum Side{
        BUY,
        SEll
    }
    struct Order{
        uint id;
        address trader;
        bool buyOrder;
        bytes32 ticker;
        uint ammount;
        uint price;
    }
    mapping(bytes32=>mapping(uint=>Order[])) orderBook;
    function getOrderBook(bytes32 ticker,Side side) public view returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }
}