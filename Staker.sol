// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;
    event Stake(address, uint256);
    uint256 public constant threshold = 1 ether;
    uint256 public deadline;
    bool public openForWithdraw = false;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
        deadline = block.timestamp + 72 hours;
    }

    function stake() public payable {
        require(block.timestamp < deadline, "It's too late to stake");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function withdraw() public payable {
        require(openForWithdraw, "withdraw aren't opened yet");
        uint256 individualBalance = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(individualBalance);
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return (deadline - block.timestamp);
    }

    receive() external payable {
        stake();
    }

    function execute() external payable {
        if (block.timestamp >= deadline && address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
            console.log("saving into external contract");
        } else if (
            block.timestamp >= deadline && address(this).balance < threshold
        ) {
            openForWithdraw = true;
            console.log("Withdraw are opened");
        }
    }

