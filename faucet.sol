// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //applying the RentrancyGaurd for security from hackers
import "@openzeppelin/contracts/security/Pausable.sol"; //applying the pausable. the contract will pause and unpause

contract Faucet is ReentrancyGuard, Pausable {

    constructor()ReentrancyGuard() {
        admin = payable(msg.sender); // deployer will be the admin
    }
    address payable admin; // address payable borrower;
    address users;
    uint public balance;//keep the track of current balance
    bool destroyer=false;//destroyer set as false

//modifier
    modifier onlyAdmin(){
    require(admin==msg.sender,"Sorry,only Admin have the access");
_;
}

// created struct for the users to keep the tract on the time of borrowed
    struct User {
        uint256 borrowed;//borrowed amount
        uint256 borrowedTime;// user borrowed time for ether
        
    }
    //mappings
    mapping(address => User) _users; //mapping used to keep the track of the users
    mapping(address => bool)public  blockedAddresses;

//Admin can inject funds to the contract
    function addFunds() public payable whenNotPaused onlyAdmin {
        require(msg.sender == admin, "Only the admin can add funds");
        require(msg.value!=0,"Please pay more than zero");
        balance += msg.value; //balance will increase
    }

//users can borrow from the contract balance
    function borrow() nonReentrant()  public payable whenNotPaused{ //modifier 
        require(0.001 ether == 0.001 ether, "You can only borrow 0.001 eth or 1000000000000000 wei from the faucet");
        require(!blockedAddresses[msg.sender], "Your address is blocked from borrowing");
        require(balance >= 0.001 ether, "Insufficient funds in the contract,please try again after sometime");
        require(_users[msg.sender].borrowed == 0 || !canBorrow(msg.sender), "You exceed the limit for today please visit tomorrow");
        _users[msg.sender].borrowed = 0.001 ether;
        _users[msg.sender].borrowedTime = block.timestamp;
        balance -= 0.001 ether;
       payable(msg.sender).transfer(0.001 ether);
      
    }

    //function withdraw helps aadmin to remove funds instantly
    function withdraw() public payable onlyAdmin() {
     require(admin == msg.sender, "only manager have access");
     admin.transfer(address(this).balance);
     balance=0;
    }
// this function checks that user
    function canBorrow(address user) internal view returns (bool) {
        return (block.timestamp - _users[user].borrowedTime) <= 1 days;// check the time elapsed of the user
    }
      //this function make sure any vulnerability in contract admin can destroy contract
    function destroy() public whenNotPaused onlyAdmin(){
        require(admin == msg.sender, "only manager have access");
        admin.transfer(address(this).balance); // contract balance will transfer to manager account
        balance =0;
        destroyer = true;  //true means destroyed
    }
//function to pause the contract
    function pause() public onlyAdmin(){
        _pause();//from Pausable.sol
    }

//function to unpause the contract
    function unpause() public onlyAdmin(){
        _unpause();//from Pausable.sol
    }
//function to block an address from borrowing
function blockAddress(address _user) public onlyAdmin() {
    blockedAddresses[_user] = true;
}

//function to unblock an addresses
function Unblock(address _user) public onlyAdmin() {
    blockedAddresses[_user] = false;
}
  
  //this function will accept ethers from outside eg: metamask
     receive() external payable {
        payable(msg.sender).transfer(msg.value); 
        balance += uint(msg.value);
    }
}
