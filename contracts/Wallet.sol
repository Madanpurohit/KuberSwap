pragma solidity >=0.6.0 <0.8.0;
import '../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../node_modules/@openzeppelin/contracts/math/SafeMath.sol';
import '../node_modules/@openzeppelin/contracts/access/Ownable.sol';
contract Wallet is Ownable{
    using SafeMath for uint256;
    struct Token{
        bytes32 ticker;
        address tokenAddress;
    }
    mapping(bytes32=>Token) public tokenMapping;
    bytes32[] public tokenList;
    mapping(address=>mapping(bytes32=>uint256)) public balances;
    function addToken(bytes32 _ticker,address _tokenAddress) external{
        tokenMapping[_ticker]=Token(_ticker,_tokenAddress);
        tokenList.push(_ticker);
    }
    function Deposit(bytes32 _ticker,uint256 _ammount) onlyOwner external{
        require(tokenMapping[_ticker].tokenAddress!=address(0),"token is not listed");
        IERC20(tokenMapping[_ticker].tokenAddress).transferFrom(msg.sender, address(this), _ammount);
        balances[msg.sender][_ticker]=balances[msg.sender][_ticker].add(_ammount);

    }
    function withdraw(uint ammount,bytes32 ticker) external{
        require(tokenMapping[ticker].tokenAddress!=address(0),"token is not listed");
        require(balances[msg.sender][ticker]>=ammount,"balance is not sufficient");
        balances[msg.sender][ticker]=balances[msg.sender][ticker].sub(ammount);
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender,ammount);
    }
}