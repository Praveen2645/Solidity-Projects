//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ecommerce {
    struct Product {
        //creting a struct of product type
        string tittle;
        string description;
        uint256 productId;
        uint256 price;
        address buyer;
        address payable seller;
        bool delivered;
    }
    
    //variables
    address payable public manager;
    bool destroyer = false; 

//constructor
    constructor() {
        manager = payable(msg.sender); // manager is set as payable, so he can send and receive ether
    }

    //events
    event registerd(string tittle, uint256 productId, address seller);
    event bought(uint256 productId, address buyer);
    event delivered(uint256 productId);

    uint256 counter = 1; // counter set to 1 for increasaing the Productids
    Product[] public products; // empty array of struct so we can track the products

//modifier
    modifier isNotdestroyed() {
        require(!destroyer, "contract does not exist"); // this modifier will help to know the whethever the contract is destroyed or not
        _;
    }

    // function for registering a products
    function registerProduct(
        string memory _title,
        string memory _description,
        uint256 _price
    ) public isNotdestroyed {
        require(_price > 0, "Price shold be greater than zero"); // condition for price should not be negative
        Product memory product; //creating an empty Product name product
        product.tittle = _title;
        product.description = _description;
        product.price = _price * 10**18; // converting ether into wei
        product.seller = payable(msg.sender);
        product.productId = counter;
        products.push(product); // pushing elemnts into an array products
        counter++; //this will help whenever we add product we will get te new id.
        emit registerd(_title, product.productId, msg.sender);
    }

    // function to buy products
    function Buy(uint256 _productId) public payable isNotdestroyed {
        require(
            products[_productId - 1].price == msg.value, //_productId-1 because, we going to check our id 1 product on idex 0.
            "Pay the exact price"
        );
        require(
            products[_productId - 1].seller != msg.sender,// condintion for seller cant be the buyer
            "seller can't buy"
        );
        products[_productId - 1].buyer = msg.sender;// one who calls the function wll be the buyer
        emit bought(_productId, msg.sender);
    }

    //to know the product has delivered or not
    function delivery(uint256 _productId) public {
        require(
            products[_productId - 1].buyer == msg.sender,// only the buyer can confirm
            "only buyer can confirm"
        );
        products[_productId - 1].delivered = true;
        products[_productId - 1].seller.transfer(
            products[_productId - 1].price // as the user confim the product is deliverd, than only the exact price will be transfered to the seller
        );
        emit delivered(_productId);
    }

    // in case any problem in your contrtact eg:- hacking, so manager can transfer all your contract balance into his own account
    function destroy() public isNotdestroyed {
        require(manager == msg.sender, "only manager have access");
        manager.transfer(address(this).balance); // contract balance will transfer to manager account
        destroyer = true;
    }

    // if contract is destroyed and someone access the contract the users ether ll not be loss
    fallback() external payable {
        payable(msg.sender).transfer(msg.value); // a fallback function is an external function with neither a name, parameters, or return values
    }
}

