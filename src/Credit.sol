// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Ownable.sol";


contract Credit is Ownable {
    
    address borrower;    //借款用户地址
    uint creditScore;   //信用评分
    uint interest;  //利息
    uint requestedAmount;   //用户申请的贷款金额
    uint returnAmount;  //用户需偿还的贷款金额，包括利息    
    uint requestedDate; //信贷创建日期
    uint repaymentDate; //偿还日期
    uint term;  //距离还款日期剩余天数
    uint interestRate; //利率 
    uint refuseThreshold;

    enum State { repayment, expired, refuse }
    State state;

    event LogCreditInitialized(address indexed _address, uint timestamp);
    event LogCreditStateChanged(State indexed state, uint timestamp);
    event LogCreditStateActiveChanged(bool indexed active, uint timestamp);

    modifier onlyBorrower() {
        require(msg.sender == borrower);
        _;
    }

    modifier canRepay() {
        require(state == State.repayment);
        _;
    }

    //用户可提现，信贷额度大于用户请求贷款金额
    modifier canWithdraw() {
        require(address(this).balance >= requestedAmount);
        _;
    }

    modifier isNotRefuse() {
        require(state != State.refuse);
        _;
    }

    constructor (uint256 _requestedAmount, uint256 _term, uint256 _interestRateConstant, uint256 _creditScore, uint256 _refuseThreshold) {

        borrower =  msg.sender;
        
        require(_creditScore > 0, "Credit score must be greater than 0");

        require(_term > 0, "Term must be greater than 0");

        term = _term;

        interestRate = (_interestRateConstant * 1000)  / _creditScore;

        interest = (_requestedAmount * interestRate) / 1000;

        requestedAmount = _requestedAmount;

        returnAmount = _requestedAmount + interest;

        creditScore = _creditScore;

        requestedDate = block.timestamp;

        refuseThreshold =  _refuseThreshold;

        emit LogCreditInitialized(borrower, block.timestamp);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance; //可借款的额度
    }

    function changeState(State _state) external onlyOwner returns (uint) {      
        state = _state;

        emit LogCreditStateChanged(state, block.timestamp);
    }


    function toggleActive() external onlyOwner returns (bool) {
        active = !active;

        emit LogCreditStateActiveChanged(active, block.timestamp);

        return active;
    }
    }  










