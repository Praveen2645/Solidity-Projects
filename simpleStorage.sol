// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract SimpleStorage{
    uint favNumber;
    mapping (string=> uint) public nameTofavNumber;

    struct People{
        string Name;
        uint favNumber;
    }
    People[] public people;

    function store(uint _favNumber) public {
        favNumber=_favNumber;
    }
    function get() public view returns(uint){
        return favNumber;
    }
    function addPeople(string memory _name, uint _favNumber)public{
        people.push(People(_name,_favNumber));
        nameTofavNumber[_name]=_favNumber;

}
}
