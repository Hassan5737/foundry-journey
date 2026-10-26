// SPDX-License-Identifier:MIT
pragma solidity ^0.8.31;

contract Vault {
    // balance mapping
    mapping (address => uint256) public balances;

    //function deposit
    function deposit() external payable {

        require(msg.value > 0, "Insufficient amount");
        balances[msg.sender] += msg.value;

    }

    // function withdraw
    function withdraw (uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount} ("");
        require(success, "withdraw failed");

    }

    // function get user balance
    function getBalance() external view returns (uint256) {

        return balances[msg.sender];
    }

}