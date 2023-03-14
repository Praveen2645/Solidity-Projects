// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lottery{
 //entities - manager,players and winner
 address public manager;
 address payable[] public players;
 address payable public winner;

  constructor(){
      manager=msg.sender;
  }
// allow  accounts(people) to participate in the lottery
  function participate() public payable{
      require(msg.sender!=manager,"manager can't participate");//owner of the contratct cant participate
      require(msg.value==1 ether,"Please pay 1 ether only");//pay the required fees(1 eth) to enter the lottery
      players.push(payable(msg.sender)); //pushing players to the "players" array.(msg.sender)-caller of the function
  }
//getting the balance of the contract
  function getBalance() public view returns(uint){
      require(manager==msg.sender,"You are not the manager");
      return address(this).balance;
  }
// this will create the random winners 
  function random() internal view returns(uint){
      return uint(keccak256(abi.encodePacked(block.prevrandao,block.timestamp,players.length)));
  }

  function pickWinner() public{
      require(manager==msg.sender,"You are not the manager");
      require(players.length>=3,"Players are less than 3");

      uint r=random();
      uint index = r%players.length;
      winner=players[index];
      winner.transfer(getBalance());
      players= new address payable[](0); //this will intiliaze the players array back to 0
  }
  //this function returns all the array of the players
  function getPlayers() public view returns(address payable [] memory){
      return players;
  }

}