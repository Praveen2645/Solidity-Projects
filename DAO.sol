// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

contract DAO {

struct Proposal{
uint id;
string description;
uint amount;
address payable receipient;
uint votes;
uint end;
bool isExecuted;
}

mapping(address=>bool) private isInvestor; // to know an address is investors or not
mapping(address=>uint) public numOfshares; // to know number of shares hold by an address
mapping(address=>mapping(uint=>bool)) public isVoted; //to check a particular address has voted for which address
mapping(uint=>Proposal) public proposals;//

address[] public investorsList; // dynamic array to keep track of investors

uint public totalShares;
uint public availableFunds;// all investment collect here 
uint public contributionTimeEnd;
uint public nextProposalId;//like counter
uint public voteTime;
uint public quorum;
address public manager;

//value passed using truffle migration file
constructor(uint _contributionTimeEnd,uint _voteTime,uint _quorum){//args1-contribution time for investor 2-voting time for proposal 3-min no of people require to pass the proposal
require(_quorum>0 && _quorum<100,"Not valid values");
contributionTimeEnd=block.timestamp+_contributionTimeEnd; //16342343342 + 2*3600
voteTime=_voteTime;
quorum=_quorum;
manager=msg.sender;
}
// only for investor
modifier onlyInvestor(){
require(isInvestor[msg.sender]==true,"You are not an investor");
_;
}
//only for mannager
modifier onlyManager(){
require(manager==msg.sender,"You are not a manager");
_;
}


// investor will contribute with this function
function contribution() public payable{
require(contributionTimeEnd>=block.timestamp,"Contribution Time Ended");//5 PM , //16342343342 + 2*3600 > 16342340000
require(msg.value>0,"Send more than 0 ether");
isInvestor[msg.sender]=true; //whoever calls the function becomes the investor
numOfshares[msg.sender]=numOfshares[msg.sender]+msg.value; // msg.value(shares) adding to the previous shares
totalShares+=msg.value; //totaltShares=totalShares+msg.value
availableFunds+=msg.value; // fund increases
investorsList.push(msg.sender); // pshing to investorslist
}

//fuction to reedem share 
function reedemShare(uint amount) public onlyInvestor(){
require(numOfshares[msg.sender]>=amount,"You don't have enough shares");
require(availableFunds>=amount,"Not enough funds");
numOfshares[msg.sender]-=amount;//shares decrease from the one who calls the function
if(numOfshares[msg.sender]==0){// if investor reedem all shares he ll no longer be the investor
isInvestor[msg.sender]=false;// investor become false
}
availableFunds-=amount;//
payable(msg.sender).transfer(amount);//transferring amount to msg.sender
}

//investor's address share will get transfered "to" address

function transferShare(uint amount,address to) public onlyInvestor(){
require(availableFunds>=amount,"Not enough funds");// to check whether funds are available or not
require(numOfshares[msg.sender]>=amount,"You don't have enough shares");
numOfshares[msg.sender]-=amount;
if(numOfshares[msg.sender]==0){// if senders share become zero!
isInvestor[msg.sender]=false; //he will no longer an investor
}
numOfshares[to]+=amount; //amount increase
isInvestor[to]=true;//to address will become true and called as an investor
investorsList.push(to);// adding to address to the investorList
}

// function for creating a proposal
function createProposal(string calldata description,uint amount,address payable receipient) public onlyManager{
require(availableFunds>=amount,"Not enough funds"); // checking for available funds
proposals[nextProposalId]=Proposal(nextProposalId,description,
amount,receipient,0,block.timestamp+voteTime,false);
nextProposalId++; //for a unique proposalId
}

//function for voting a propsal
function voteProposal(uint proposalId) public onlyInvestor(){
Proposal storage proposal = proposals[proposalId];//creating variable proposal
require(isVoted[msg.sender][proposalId]==false,"You have already voted for this proposal");
require(proposal.end>=block.timestamp,"Voting Time Ended");
require(proposal.isExecuted==false,"It is already executed");
require(isVoted[msg.sender][proposalId]=true,"You already voted for this proposal");//checking for the double vote on same id
proposal.votes+=numOfshares[msg.sender];//proposal.votes=proposal.votes+numOfshares[msg.sender]
}//no of shares of caller will be equal to the number of shares

// executing the choosed propsal
function executeProposal(uint proposalId) public onlyManager(){
Proposal storage proposal=proposals[proposalId];
require(((proposal.votes*100)/totalShares)>=quorum,"Majority does not support"); 
proposal.isExecuted=true;//propasal passed the above require then set isExecuted as true
availableFunds-=proposal.amount;//decreasing the amount from the available fund
_transfer(proposal.amount,proposal.receipient);//using _transffer function 
}

//transfer of amount when proposal executed
function _transfer(uint amount,address payable receipient) private{
receipient.transfer(amount);
}

//function to get a list of all propsals
function ProposalList() public view returns(Proposal[] memory){
Proposal[] memory arr = new Proposal[](nextProposalId);//empty array of length=nextProposalId-1, -1 because last id created and to balance it -1.  
for(uint i=0;i<nextProposalId;i++){
arr[i]=proposals[i];
}
return arr;
}

//function for the investors list
function InvestorList() public view returns(address[] memory){
  return investorsList;
}
}
