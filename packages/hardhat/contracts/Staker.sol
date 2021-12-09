pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staker is Ownable{

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  event Stake(address indexed sender,string message);
  event Withdraw(address indexed sender, string message);
  uint256 public deadline = now + 30 minutes;

  constructor(address exampleExternalContractAddress) public {
      //exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      
  }

   // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() payable public {
    require(msg.value > 0, "Amount need to be greater than 0");
    require(now <= deadline, "Can only stake before deadline.");
    balances[msg.sender] += msg.value;
    
    emit Stake(msg.sender, string(abi.encodePacked(msg.value)));
  }
  
  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public 
  {
    require(now > deadline, "Deadline has not reached yet");
    require(address(this).balance >= threshold , "Threshold has not reached");
    exampleExternalContract.complete{value: address(this).balance}();
    
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public 
  {
    require(now > deadline,"Deadline has not reached yet");
    require(balances[msg.sender] > 0, "You havent stake");
    require(exampleExternalContract.completed() == false, "The staking has completed");
    uint256 balAmount = balances[msg.sender];
    balances[msg.sender] = 0;
    //address(this).balance -= balAmount;
    msg.sender.transfer(balAmount);    
    emit Withdraw(msg.sender, "Withdraw");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256)
  {
    if(now >= deadline)
    {
      return 0;
    }
    else
    {
      return deadline - now;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable
  {
    stake();
  }

}
