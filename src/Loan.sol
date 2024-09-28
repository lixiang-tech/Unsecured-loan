// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Credit.sol";
import "./Ownable.sol";

contract Loan is Ownable {

    struct User {

        bool isCredited; //用户是否申请过信贷合同，true：申请过；flase：没申请过

        address creditAddress;  //用户的信贷地址

        bool refuseStatus;  //是否由于信用评分不合格而被拒绝借贷，true：被拒绝借款；flase：可以借款

    }

    mapping(address => User) public users; //存储用户信息

    address[] public allCreditAddress; //存储所有用户的信贷地址
    
    event LogCreditCreated(address indexed _address, address indexed _borrower, uint  timestamp);
    event LogCreditStateChanged(address indexed _address, Credit.State state, uint256 timestamp);
    event LogCreditActiveChanged(address indexed _address, bool active, uint256 timestamp);
    event LogUserSetRefuseStatus(address indexed _address, bool refuseStatus, uint timestamp);
    /*用户申请信贷
    requestedAmount : 用户申请的贷款金额
    term：还款期限
    creditScore ：信用评分  
    interest ： 利息
    creditAddress ： 用户信贷地址
    */
    function applyForCredit ( uint256 _requestedAmount, uint256 _term, uint256 _interestRateConstant, uint256 _creditScore) public returns(address _creditAddress) {
        
        require(users[msg.sender].isCredited == false,"Applied credit");  //用户之前没有申请过此信贷

        require(users[msg.sender].refuseStatus == false,"Failed credit score");  //用户信用评分合格，可以借款
        
        assert(users[msg.sender].creditAddress == address(0));  //检查用户地址

        users[msg.sender].isCredited = true;  //标记为已申请过此信贷，防止重入

        Credit credit = new Credit(_requestedAmount, _term, _interestRateConstant, _creditScore);   

        users[msg.sender].creditAddress = address(credit); //把合同地址赋值给用户地址

        allCreditAddress.push(address(credit));

        emit LogCreditCreated(address(credit), msg.sender, block.timestamp);

        return address(credit);
    }  

    function getCredits() public view returns (address[] memory) {
        return allCreditAddress;
    }

    function setRefuseStatus(address _borrower) external returns (bool) {

        users[_borrower].refuseStatus = true;

        emit LogUserSetRefuseStatus(_borrower, users[_borrower].refuseStatus, block.timestamp);

        return users[_borrower].refuseStatus; 
    }

    function changeCreditState (Credit _credit, Credit.State state) public onlyOwner {

        _credit.changeState(state);

        emit LogCreditStateChanged(address(_credit), state, block.timestamp);
    }

    function changeCreditActivetState (Credit _credit) public onlyOwner {

        bool active = _credit.toggleActive();

        emit LogCreditActiveChanged(address(_credit), active, block.timestamp);
    }



}