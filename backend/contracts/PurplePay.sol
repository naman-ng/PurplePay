// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title PurplePay task
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "hardhat/console.sol";


contract PurplePay {
    address public admin;
    uint256 public adminFeePercentage;
    uint256 public totalFeeCollected; 

    mapping (address => mapping(address => uint256)) public userData;

    event Deposit(address indexed _from, address indexed _tokenAddress, uint256 _amount);
    event Withdraw(address indexed _to, address indexed _tokenAddress, uint256 _amount);

    constructor() {
        admin = msg.sender;
        adminFeePercentage = 1;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin is allowed");
        _;
    }

    function deposit(address _tokenAddress, uint256 _amount) external {
        IERC20 token = IERC20(_tokenAddress);

        // console.log("Starting transferFrom: %s", address(token));
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        
        uint256 adminFee = _amount * adminFeePercentage / 100;
        totalFeeCollected += adminFee;
        userData[msg.sender][_tokenAddress] += (_amount - adminFee);
        
        require(token.transfer(admin, adminFee), "Admin fee transfer failed");

        emit Deposit(msg.sender, _tokenAddress, _amount);
    }

    function withdraw(address _tokenAddress, uint256 _amount) external {
        address sender = msg.sender;
        require(userData[sender][_tokenAddress] >= _amount, "Insufficient balance");
        userData[sender][_tokenAddress] -= _amount;
        IERC20 token = IERC20(_tokenAddress);
        require(token.transfer(sender, _amount), "Token transfer failed");

        emit Withdraw(sender, _tokenAddress, _amount);
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid admin address");
        admin = _newAdmin;
    }

    function setAdminFeePercentage(uint256 _adminFeePercentage) external onlyAdmin {
        require(_adminFeePercentage <= 100, "Invalid Admin Fee Percentage");
        adminFeePercentage = _adminFeePercentage;
    }

    function getAdminFeePercentage() external view returns (uint256){
        return adminFeePercentage;
    }

    function getAdmin() external view returns (address){
        return admin;
    }

    function getTotalFeeCollected() external view returns (uint256){
        return totalFeeCollected;
    }
}