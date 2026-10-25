// SPDX-License-Identifier:MIT
pragma solidity ^0.8.31;

contract Vault {
    // balance mapping
    mapping (address => uint256) private balances;

    //function deposit
    function deposit() external payable {

        require(msg.value > 0, "Insufficient amount");
        balances[msg.sender] += msg.value;

    }

    // function withdraw
    function withdraw (uint256 amount) external {

    }

    // function get user balance
    function getBalance() external view returns (uint256) {

        return balances[msg.sender];
    }

}