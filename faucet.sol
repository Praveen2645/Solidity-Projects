// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Faucet {
    address payable admin; // address payable borrower;
    uint public balance;//keep the track of current balance
    bool destroyer=false;//destroyer set as false

// created struct for the users to keep the tract on the time of borrowed
    struct User {
        uint256 borrowed;//borrowed amount
        uint256 borrowedTime; // user borrowed time for ether
    }
    mapping(address => User) _users; //mapping used to keep the track of the users

    constructor() {
        admin = payable(msg.sender); // deployer will be the admin
    }

//Admin can inject funds to the contract
    function addFunds() public payable {
        require(msg.sender == admin, "Only the admin can add funds");
        balance += msg.value; //balance will increase
    }

//users can borrow from the contract balance
    function borrow(uint _amount) public {
        require(_amount == 0.001 ether, "You can only borrow 0.001 eth or 1000000000000000 wei from the faucet");
        require(balance >= _amount, "Insufficient funds in the contract,please try again after sometime");
        require(_users[msg.sender].borrowed == 0 || !canBorrow(msg.sender), "You exceed the limit for today please visit tomorrow");
        _users[msg.sender].borrowed = _amount;
        _users[msg.sender].borrowedTime = block.timestamp;
        balance -= _amount;
       payable(msg.sender).transfer(_amount);
      
    }
// this function checks that user
    function canBorrow(address user) internal view returns (bool) {
        return (block.timestamp - _users[user].borrowedTime) <= 1 days;// check the time elapsed of the user
    }
    
    //this function make sure any vulnerability in contract admin can destroy contract
    function destroy() public {
        require(admin == msg.sender, "only manager have access");
        admin.transfer(address(this).balance); // contract balance will transfer to manager account
        destroyer = true;//destroyer assigns to true
    }
    
  //this function will accept ethers from outside eg: metamask
     receive() external payable {
        payable(msg.sender).transfer(msg.value); 
        balance += uint(msg.value);
    }
}
