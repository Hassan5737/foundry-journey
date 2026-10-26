// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;

    address user = makeAddr("user");

    function setUp() public {
        vault = new Vault();
        vm.deal(user, 10 ether);
    }



                   // AAA testing 

    // test function 1
    function test_deposit() public  {

        // Arrange

        //Act
        vm.prank(user);
        vault.deposit {value: 1 ether}();


        //Assert
        vm.prank(user);
        assertEq(vault.getBalance() , 1 ether);
        
    }

    // test function 2
    function test_deposit_zero_Amount() public {

        vm.expectRevert("Insufficient amount");
        vault.deposit();
    }

    // test function 3
    function test_withdraw() public {

        uint withdrawAmount = 1 ether;
        // deposit 2 ether
        vm.startPrank(user);
        vault.deposit{value: 2 ether}();

        // withdraw 1 ether
        uint balanceBefore = user.balance;
        vault.withdraw(withdrawAmount);
        uint balanceAfter = user.balance;
        vm.stopPrank();

        // check balance
        assertEq(vault.balances(user) , 1 ether);

        // check user balance
        assertEq(balanceAfter, balanceBefore + withdrawAmount);
    }

    function test_withdraw_Revert_If_Insufficient_Balance() public {
        vm.startPrank(user);
        vault.deposit {value: 1 ether}();
        vm.expectRevert("Insufficient balance");
        vault.withdraw(2 ether);
        vm.stopPrank();
    } 
}