//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract StudentRecords {
    //structure of the student
    struct student {
        uint256 roll;
        string name;
        uint256[3] marks;
    }
    address teacher; // variable teacher
    uint256 public
    studentCount;// studentCount variable to keep the count of the students

    //mapping roll to stuct{student} and named it studentDetails
    mapping(uint256 => student)  studentDetails;

//declaring constructor and making teacher as a owner of this contract
    constructor() {
        teacher = msg.sender;
    }

//modifier for teacher as we want teacher to handle the smart contract 
    modifier onlyTeacher() {
        require(teacher == msg.sender, "only teacher have access");
        _;
    }

// this function add the student records, only by the teacher
    function addRecords(
        uint256 _roll,
        string memory _name,
        uint256[3] memory _marks
    ) public onlyTeacher {
        require(_roll!=0,"Please enter valid roll number");
        studentDetails[_roll] = student(_roll, _name, _marks); // storing records to the mapping{studentDetails}
        studentCount++;// increasing the student count
    }

//function for getting records from mapping, as we enter the roll number we will get the details of the student mapped to the particular roll number
    function getRecords(uint256 _roll)
        public
        view
        onlyTeacher
        returns (student memory)
    {
        require(studentDetails[_roll].roll != 0, "Record does not exist");//we want our roll number should not be zero
        return studentDetails[_roll];
    }

//function to delete a particular record
    function deleteRecords(uint256 _roll) public onlyTeacher {
        delete studentDetails[_roll];
    }
}

