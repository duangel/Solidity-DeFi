// SPDX-License-Identifier: XXX

pragma solidity >=0.8.10;

import "./interfaces/IERC20.sol";
import "./libraries/SafeMath.sol";

contract BudgyToken is IERC20 {
  using SafeMath for uint256;

  uint256 public constant _totalSupply = 10**12;
  string public constant name = 'Budgy Token';
  uint8 public constant decimals = 10;
  string public constant symbol = 'BDGY';
  string private constant secretMessage = 'You have unlocked the secret message. The secret to happiness are bird seeds.';


  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;


  constructor () {
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender , _totalSupply);
  }

  function totalSupply() external override pure returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public override view returns (uint256) {
    return _balances[owner];
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

  function VIPOnlyCommunityGiving(address owner, address to, uint256 amount) public returns(string memory){
      uint256 acctBalance = _balances[owner];
      if (acctBalance>_totalSupply/2){
          if (amount==0){
              amount = randomGenerator(acctBalance);
              transferFrom(owner, to, amount);
              return('Sharing means caring. You did not want to share, so we are now sending a random amount of tokens to the other account. You also will not see the Secret Message. Boo.');
          }
          transferFrom(owner, to, amount);
          return secretMessage;
      }
      return 'Not enough tokens to join the club, sorry!';
    }

}