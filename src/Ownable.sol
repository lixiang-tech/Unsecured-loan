// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {

    constructor() {
        owner = msg.sender;
        active = true;
    }

    address public owner;
    bool public active;

    event ContractPaused(uint timestamp);
    event FundsWithdrawn(address indexed recipient, uint amount, uint contractBalance, uint timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier isActive() {
        require(active, "Contract is paused");
        _;
    }

    function pauseContract() public onlyOwner {
        active = false;
        emit ContractPaused(block.timestamp);
    }

    function withdrawFunds(address payable _recipient) public onlyOwner isActive {
        uint balance = address(this).balance;
        require(balance > 0, "No funds available");
        _recipient.transfer(balance);
        emit FundsWithdrawn(_recipient, balance, address(this).balance, block.timestamp);
    }

    // 允许合约接收以太币
    receive() external payable {}

}



