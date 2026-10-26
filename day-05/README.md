# Foundry Testing: Withdrawals, Reverts & Caller Simulation

## Overview

Day 05 focuses on testing withdrawal functionality in the `Vault` smart contract using Foundry. The goal was to cover successful transactions, expected failures, user balances, and caller simulation.

## Topics Covered

- **Expect Revert:** Verify that a transaction fails with the expected revert reason.
- **Testing Withdrawals:** Check both the internal vault balance and the user's ETH balance.
- **Caller Simulation:** Use `vm.prank()` to simulate one call from a specific address.
- **Start and Stop Prank:** Use `vm.startPrank()` and `vm.stopPrank()` to simulate multiple calls from the same address.
- **User Balances:** Verify account-specific balances using `balances(user)` and `getBalance()`.
- **Negative Testing:** Ensure invalid operations revert as expected.
- **Foundry MCQ #1:** Complete the first Foundry multiple-choice exercise.

## Project Setup

The test contract uses Foundry's `Test` utilities and deploys a fresh `Vault` instance before each test.

```solidity
Vault public vault;

address user = makeAddr("user");

function setUp() public {
    vault = new Vault();
    vm.deal(user, 10 ether);
}
```

- `makeAddr()` creates a deterministic test address.
- `vm.deal()` assigns ETH to the test user.
- `setUp()` prepares the environment for each test independently.

## 1. Testing Deposits

### Successful Deposit

The test simulates a deposit of `1 ether` from the user and verifies the resulting vault balance.

```solidity
vm.prank(user);
vault.deposit{value: 1 ether}();

vm.prank(user);
assertEq(vault.getBalance(), 1 ether);
```

**Key concept:** `vm.prank(user)` changes the sender for the next relevant call, allowing the test to execute the deposit as the intended user.

### Zero-Amount Deposit

```solidity
vm.expectRevert("Insufficient amount");
vault.deposit();
```

The test verifies that depositing zero ETH reverts with the expected reason.

## 2. Testing Withdrawals

The withdrawal test deposits `2 ether` and withdraws `1 ether`.

```solidity
uint withdrawAmount = 1 ether;

vm.startPrank(user);
vault.deposit{value: 2 ether}();

uint balanceBefore = user.balance;
vault.withdraw(withdrawAmount);
uint balanceAfter = user.balance;

vm.stopPrank();

assertEq(vault.balances(user), 1 ether);
assertEq(balanceAfter, balanceBefore + withdrawAmount);
```

The test checks two independent results:

1. **Vault accounting:** The user's recorded vault balance decreases from `2 ether` to `1 ether`.
2. **Wallet balance:** The user's ETH balance increases by the withdrawn amount.

`vm.startPrank(user)` simulates consecutive calls from the same address, while `vm.stopPrank()` ends that simulation.

## 3. Testing Withdrawal Reverts

### Insufficient Balance

```solidity
vm.startPrank(user);
vault.deposit{value: 1 ether}();

vm.expectRevert("Insufficient balance");
vault.withdraw(2 ether);

vm.stopPrank();
```

The user deposits `1 ether` and attempts to withdraw `2 ether`.

The test expects the withdrawal to revert because the requested amount exceeds the user's recorded vault balance.

**Key concept:** Negative tests verify that a contract rejects invalid operations instead of allowing an incorrect state transition.

## Vault Contract

The contract maintains user balances in a mapping and exposes deposit, withdrawal, and balance-query functions.

```solidity
mapping(address => uint256) public balances;

function deposit() external payable {
    require(msg.value > 0, "Insufficient amount");
    balances[msg.sender] += msg.value;
}

function withdraw(uint256 amount) external {
    require(
        balances[msg.sender] >= amount,
        "Insufficient balance"
    );

    balances[msg.sender] -= amount;

    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "withdraw failed");
}

function getBalance() external view returns (uint256) {
    return balances[msg.sender];
}
```

### Contract Logic

- `deposit()` rejects zero-value deposits and updates the sender's recorded balance.
- `withdraw()` checks the available balance, updates accounting, and transfers ETH to the caller.
- `getBalance()` returns the recorded balance of the caller.
- `balances(address)` provides direct access to the recorded balance for a specified address.

## Test Coverage

| Test | Expected behavior |
|---|---|
| `test_deposit` | A successful deposit updates the user's vault balance |
| `test_deposit_zero_Amount` | A zero-value deposit reverts |
| `test_withdraw` | Withdrawal updates vault accounting and the user's wallet balance |
| `test_withdraw_Revert_If_Insufficient_Balance` | An excessive withdrawal reverts |

## Key Takeaways

- Tests should verify state changes, not just whether a function completes.
- `vm.prank()` is useful for simulating a single caller-specific interaction.
- `vm.startPrank()` and `vm.stopPrank()` help test sequences of calls from one address.
- `vm.expectRevert()` checks that invalid operations fail as expected.
- Testing both contract accounting and wallet balances provides stronger withdrawal coverage.
- Negative tests are essential for verifying contract restrictions.

## Summary

Day 05 strengthened my understanding of Foundry testing by covering deposits, withdrawals, expected reverts, user balance verification, and caller simulation.

The focus was on writing tests that verify both successful state transitions and the contract's behavior when an operation should fail.
