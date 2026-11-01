// SPDX-License-Identifier:MIT
pragma solidity ^0.8.31;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    function run() external {
        vm.startBroadcast();

        Vault vault = new Vault();

        vault.deposit{value: 1 ether} ();

        uint256 balance = vault.getBalance();

        console.log("balance: ", balance ); 

        vm.stopBroadcast();
    }
}