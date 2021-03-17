pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;
import './Wallet.sol';
import '../node_modules/@openzeppelin/contracts/math/SafeMath.sol';
contract Dex is Wallet{
    using SafeMath for uint256;
    enum Side{
        BUY,
        SELL
    }
    uint256 public unique_id=0;
    struct Order{
        uint id;
        address trader;
        Side side;
        uint ammount;
        uint price;
    }
    mapping(bytes32=>mapping(uint=>Order[])) orderBook;
    function getOrderBook(bytes32 ticker,Side side) public view returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }
    function createLimitOrder(Side side,bytes32 ticker,uint ammount,uint price) public{
        if(side==Side.BUY){
            require(balances[msg.sender]['ETH']>=ammount.mul(price));
        }
        else if(side==Side.SELL){
            require(balances[msg.sender][ticker]>=ammount);
        }
        Order[] storage _order=orderBook[ticker][uint(side)];
        _order.push(Order(unique_id,msg.sender,side,ammount,price));
        if(side==Side.BUY){
            for(uint256 i=0;i<_order.length-1;i++){
                for(uint256 j=0;j<_order.length-1-i;j++){
                    if(_order[j].price<_order[j+1].price){
                        Order memory temp=_order[j];
                        _order[j]=_order[j+1];
                        _order[j+1]=temp;
                    }
                }
            }
        }
        else{
            for(uint256 i=0;i<_order.length-1;i++){
                for(uint256 j=0;j<_order.length-1-i;j++){
                    if(_order[j].price>_order[j+1].price){
                        Order memory temp=_order[j];
                        _order[j]=_order[j+1];
                        _order[j+1]=temp;
                    }
                }
            }
        }
    }
}