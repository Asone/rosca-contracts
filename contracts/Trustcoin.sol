/**
 *  Trustcoin contract, code based on multiple sources:
 *
 *  https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20.sol
 *  https://github.com/golemfactory/golem-crowdfunding/tree/master/contracts
 *  https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/HumanStandardToken.sol
 */

pragma solidity ^0.4.8;

import './deps/ERC20TokenInterface.sol';
import './deps/SafeMath.sol';

contract Trustcoin is ERC20TokenInterface, SafeMath {

  string public constant name = 'Trustcoin';
  uint8 public constant decimals = 18;
  string public constant symbol = 'TRST';
  string public constant version = 'TRST1.0';
  uint256 public totalSupply = 100000000; // One hundred million (ERC20)
  uint256 public totalMigrated; // Begins at 0 and increments if tokens are migrated to a new contract
  address public newToken; // Address of the new token contract

  mapping(address => uint) public balances; // (ERC20)
  mapping (address => mapping (address => uint)) public allowed; // (ERC20)

  address public migrationMaster;

  event OutgoingMigration(address owner, uint256 value);

  modifier onlyFromMigrationMaster() {
    if (msg.sender != migrationMaster) throw;
    _;
  }

  function Trustcoin(address _migrationMaster) {
    if (_migrationMaster == 0) throw;
    migrationMaster = _migrationMaster;
  }

  // See ERC20
  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  // See ERC20
  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  // See ERC20
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  // See ERC20
  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  // See ERC20
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  //
  //  Migration methods
  //

  /**
   *  Changes the owner for the migration behaviour
   *  @param _master Address of the new migration controller
   */
  function changeMigrationMaster(address _master) onlyFromMigrationMaster external {
    if (_master == 0) throw;
    migrationMaster = _master;
  }

  /**
   *  Sets the address of the new token contract, so we know who to
   *  accept discardTokens() calls from, and enables token migrations
   *  @param _newToken Address of the new Trustcoin contract
   */
  function setNewTokenAddress(address _newToken) onlyFromMigrationMaster external {
    if (newToken != 0) throw; // Ensure we haven't already set the new token
    if (_newToken == 0) throw; // Paramater validation
    newToken = _newToken;
  }

  /**
   *  Burns the tokens from an address and increments the totalMigrated
   *  by the same value. Only called by the new contract when tokens
   *  are migrated.
   *  @param _from Address which holds the tokens
   *  @param _value Number of tokens to be migrated
   */
  function discardTokens(address _from, uint256 _value) external {
    if (newToken == 0) throw; // Ensure that we have set the new token
    if (msg.sender != newToken) throw; // Ensure this function call is initiated by the new token
    if (_value == 0) throw;
    if (_value > balances[_from]) throw;
    balances[_from] = safeSub(balances[_from], _value);
    totalSupply = safeSub(totalSupply, _value);
    totalMigrated = safeAdd(totalMigrated, _value);
    OutgoingMigration(_from, _value);
  }

}