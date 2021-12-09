pragma solidity >=0.6.0 <0.7.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ExampleExternalContract  {

  bool public completed;

  function complete() public payable {
    completed = true;
    // transfer the money into this contract address
  }

  function getBalance() public view returns(uint256){
    return address(this).balance;
  }

}
