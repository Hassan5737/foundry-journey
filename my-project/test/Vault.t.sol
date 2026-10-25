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

    
}