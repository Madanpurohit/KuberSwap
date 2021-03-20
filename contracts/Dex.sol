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
        uint filled;
    }
    mapping(bytes32=>mapping(uint=>Order[])) public orderBook;
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
        _order.push(Order(unique_id,msg.sender,side,ammount,price,0));
        unique_id++;
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
    function createMarketOrder(Side side, bytes32 ticker, uint amount) public{
        if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount, "Insuffient balance");
        }
        
        uint orderBookSide;
        if(side == Side.BUY){
            orderBookSide = 1;
        }
        else{
            orderBookSide = 0;
        }
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint totalFilled = 0;

        for (uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            uint leftToFill = amount.sub(totalFilled);
            uint availableToFill = orders[i].ammount.sub(orders[i].filled);
            uint filled = 0;
            if(availableToFill > leftToFill){
                filled = leftToFill; //Fill the entire market order
            }
            else{ 
                filled = availableToFill; //Fill as much as is available in order[i]
            }

            totalFilled = totalFilled.add(filled);
            orders[i].filled = orders[i].filled.add(filled);
            uint cost = filled.mul(orders[i].price);

            if(side == Side.BUY){
                //Verify that the buyer has enough ETH to cover the purchase (require)
                require(balances[msg.sender]["ETH"] >= cost);
                //msg.sender is the buyer
                balances[msg.sender][ticker] = balances[msg.sender][ticker].add(filled);
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].sub(cost);
                
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].sub(filled);
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].add(cost);
            }
            else if(side == Side.SELL){
                //Msg.sender is the seller
                balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(filled);
                balances[msg.sender]["ETH"] = balances[msg.sender]["ETH"].add(cost);
                
                balances[orders[i].trader][ticker] = balances[orders[i].trader][ticker].add(filled);
                balances[orders[i].trader]["ETH"] = balances[orders[i].trader]["ETH"].sub(cost);
            }
            
        }
            //Remove 100% filled orders from the orderbook
        while(orders.length > 0 && orders[0].filled == orders[0].ammount){
            //Remove the top element in the orders array by overwriting every element
            // with the next element in the order list
            for (uint256 i = 0; i < orders.length - 1; i++) {
                orders[i] = orders[i + 1];
            }
            orders.pop();
        }
        
    }

}