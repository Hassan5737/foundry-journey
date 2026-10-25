#  Smart Contract Testing with Foundry

## Overview

Today, I continued my journey into smart contract testing using Foundry. I explored how to run tests, structure them using the Arrange–Act–Assert (AAA) pattern, simulate transactions from specific addresses, send ETH to payable functions, and verify results with assertions.

I applied these concepts to my `Vault` smart contract by creating the initial `test_deposit` unit test.

## 1. Running Tests with Foundry

Foundry provides the `forge test` command to discover, compile, and execute Solidity tests.

Run this command from the `my-project` directory:

```bash
forge test
```

To run a specific test function:

```bash
forge test --match-test test_deposit
```

To display more detailed execution information:

```bash
forge test -vv
```

Foundry discovers test functions whose names begin with `test`. A successful compilation alone does not mean that tests were executed, so it is important to check the test results.

## 2. The Arrange–Act–Assert (AAA) Pattern

AAA is a testing structure that organizes a test into three clear stages.

### Arrange

Prepare the required state and inputs before executing the behavior being tested.

In this project, `setUp()` creates a new `Vault` instance and provides the test user with an ETH balance.

```solidity
function setUp() public {
    vault = new Vault();
    vm.deal(user, 10 ether);
}
```

Foundry runs `setUp()` before each test function.

### Act

Execute the function or behavior that the test is intended to verify.

```solidity
vm.prank(user);
vault.deposit{value: 1 ether}();
```

This simulates a call from `user` and sends `1 ether` to the payable `deposit()` function.

### Assert

Check whether the observed result matches the expected result.

```solidity
vm.prank(user);
assertEq(vault.getBalance(), 1 ether);
```

The test verifies that the user's recorded Vault balance equals `1 ether`.

Separating a test into Arrange, Act, and Assert makes its purpose easier to understand and maintain.

## 3. `vm.prank()`: Simulating a Caller

`vm.prank(address)` is a Foundry cheatcode that makes the next eligible call execute with the specified address as `msg.sender`.

Example:

```solidity
vm.prank(user);
vault.deposit{value: 1 ether}();
```

This allows the test to simulate a transaction initiated by `user` without requiring a separate wallet.

A single `vm.prank()` applies to the next eligible call. For multiple consecutive calls from the same simulated address, Foundry also provides `vm.startPrank()` and `vm.stopPrank()`.

## 4. Sending ETH to a Payable Function

A Solidity function marked `payable` can receive ETH.

The `Vault` contract exposes this function:

```solidity
function deposit() external payable {
    require(msg.value > 0, "Insufficient amount");
    balances[msg.sender] += msg.value;
}
```

A test can send ETH to this function using a value call:

```solidity
vm.prank(user);
vault.deposit{value: 1 ether}();
```

The `{value: 1 ether}` call option specifies the ETH amount sent with the transaction. Inside `deposit()`, `msg.value` represents the amount received, while `msg.sender` identifies the caller.

The contract records the deposited amount against the caller's address.

## 5. `assertEq()`: Verifying Expected Results

`assertEq(actual, expected)` is an assertion helper provided by `forge-std/Test.sol`.

Example:

```solidity
assertEq(vault.getBalance(), 1 ether);
```

The test passes when the actual balance equals the expected value. If the values differ, the assertion fails and Foundry reports the failure.

Assertions turn expected contract behavior into checks that can be executed repeatedly.

## 6. Practical Implementation: Testing Vault Deposits

The current test uses the concepts above to verify a basic deposit:

```solidity
function test_deposit() public {
    // Arrange
    // The Vault and funded user are prepared in setUp().

    // Act
    vm.prank(user);
    vault.deposit{value: 1 ether}();

    // Assert
    vm.prank(user);
    assertEq(vault.getBalance(), 1 ether);
}
```

The test checks that depositing `1 ether` through the `Vault` contract increases the caller's recorded balance to `1 ether`.

This is the initial unit test for the deposit behavior. Additional tests can later cover other scenarios, such as zero-value deposits and withdrawal behavior.

## Key Takeaways

- `forge test` runs the project's discovered tests.
- AAA separates test preparation, execution, and verification.
- `vm.prank()` simulates the caller of the next eligible call.
- `{value: ...}` sends ETH to a payable function.
- `assertEq()` checks whether actual and expected values are equal.
- `setUp()` prepares a fresh testing environment before each test.

## References

- [Foundry Book: Writing Tests](https://book.getfoundry.sh/forge/writing-tests)
- [Foundry Book: Forge Standard Library](https://book.getfoundry.sh/reference/forge-std)
- [Mastering Ethereum](https://drive.google.com/file/d/17KxJNm__WflQLtBosOSrNg5G-0cs1clR/view?usp=sharing)
