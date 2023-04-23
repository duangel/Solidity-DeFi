// SPDX-License-Identifier: XXX

// BDGY says that if you are the 5th, 10th, 15th, etc. user of this contract, you get 
// a special thank you message
// if you refer a friend, then you get an extra 0.001 BDGY and they get 0.0005 BDGY extra
pragma solidity >=0.8.10;

import "./interfaces/IERC20.sol";
import "./libraries/SafeMath.sol";

struct User {
    uint256 id;
    // other stuff

    bool set; // This boolean is used to differentiate between unset and zero struct values
}

contract BudgyToken is IERC20 {
  using SafeMath for uint256;

  uint256 public constant _totalSupply = 10**18;
  string public override constant name = 'Budgy Token';
  uint8 public override constant decimals = 10;
  string public override constant symbol = 'BDGY';
  string private constant secretMessage = 'You have unlocked the secret message. The secret to happiness are bird seeds.';
  uint256 public unitsOneEthCanBuy  = 42;
  address[] userIDs;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;
  
  mapping(address => User) public users;

  address public tokenOwner;

  constructor () {
    tokenOwner = msg.sender;  
    _balances[tokenOwner] = _totalSupply;
    //_balances[msg.sender] = _totalSupply;
    //emit Transfer(address(0), msg.sender , _totalSupply);
    emit Transfer(address(0), tokenOwner , _totalSupply);
  }

  receive() external payable {
    // code taken from https://levelup.gitconnected.com/minting-your-own-erc-20-tokens-in-ethereum-a477bd38c135    

    uint256 amount = msg.value * unitsOneEthCanBuy;

    require(balanceOf(tokenOwner) >= amount, 
        "Not enough tokens");

    _transfer(tokenOwner, msg.sender, amount);
     
    emit Transfer(tokenOwner, msg.sender, amount);

    payable(tokenOwner).transfer(msg.value);
    }


  function totalSupply() external override pure returns (uint256) {
    return _totalSupply;
  }

  

  function balanceOf(address owner) public override view returns (uint256) {
    return _balances[owner];
  }

  function createUser(address _userAddress, uint256 _userId) public returns (address[] memory){
    User storage user = users[_userAddress];
    // Check that the user did not already exist:
    require(!user.set);
    //Store the user
    users[_userAddress] = User({
        id: _userId,
        set: true
    });
    userIDs.push(_userAddress);

    return userIDs;
  }

  /**
  * Function to check the amount of tokens that an owner allowed to a spender.
  */
  function allowance(address owner,address spender)public override view returns (uint256){
    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public override returns (bool) {
    require(value <= _balances[msg.sender]);
    require(to != address(0));

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public override returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function _transfer(address from, address to, uint value) private {
      _balances[from] = _balances[from].sub(value);
      _balances[to] = _balances[to].add(value);
      emit Transfer(from, to, value);
    }

  function transferFrom( address from, address to, uint256 value) public override returns (bool){
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  function increaseAllowance( address spender, uint256 addedValue ) public returns (bool){
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender,uint256 subtractedValue) public returns (bool){
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function randomGenerator(uint256 number) public view returns (uint256){
      return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, msg.sender))) % number;
  }
  
  function array_length() public view returns(uint256) {  
        uint256 x = userIDs.length;
        return x; 
    } 
  

  function VIPOnly(address owner, address friend) public returns(string memory){
      uint256 numOfOGTokens = _balances[tokenOwner];
      uint256 numOfUsers = array_length();
      if (numOfUsers % 5 == 0 && numOfOGTokens >= 3){

          transferFrom(tokenOwner, friend, 2);
          transferFrom(tokenOwner, owner, 1);

          return secretMessage;
      }
      return 'Sorry, better luck next time getting into our flock!';
    }

}