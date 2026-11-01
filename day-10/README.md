# Third-Party Solidity Libraries with Foundry

## Overview

Smart contract developers do not need to implement every common feature from scratch. Third-party libraries provide reusable, documented components that can be integrated into Solidity projects.

In this lesson, we installed **OpenZeppelin Contracts** in a Foundry project, configured an import remapping in `foundry.toml`, and imported the ERC-20 implementation into a Solidity source file.

This guide explains:
- What third-party Solidity libraries are and why they are useful.
- What OpenZeppelin Contracts provides.
- How to install OpenZeppelin with Foundry.
- How dependencies are organized in `lib/`.
- How import remappings work.
- How to import, inherit from, and use an OpenZeppelin contract.
- Dependency-management and security practices.

---

## 1. What Is a Third-Party Solidity Library?

A third-party library is reusable code maintained outside your own project. Instead of implementing every common feature yourself, you can install a package and import the components you need.

Solidity dependencies commonly provide:
- Implementations of widely used token standards.
- Access-control and ownership mechanisms.
- Reusable utilities and helper functions.
- Cryptographic and signature-related functionality.
- Components for building more complex protocol features.

### Why use existing libraries?

1. **Reusability:** Common functionality can be reused across projects.
2. **Consistency:** Standard implementations help avoid accidental differences in behavior.
3. **Development efficiency:** Developers can focus on application logic instead of repeatedly implementing established components.
4. **Review and testing:** Widely used libraries receive attention from maintainers and the developer community.
5. **Maintainability:** A dependency with a documented API and release history is easier to manage than copied code.

A library is not automatically safe merely because it is popular. Developers must still select appropriate versions, understand the code they depend on, and test their own contracts.

---

## 2. Introduction to OpenZeppelin Contracts

[OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/5.x/) is a library of reusable Solidity components for Ethereum smart contract development.

It includes implementations and utilities for common standards and patterns:

| Area | Examples |
|---|---|
| Fungible tokens | ERC-20 |
| Non-fungible tokens | ERC-721 |
| Multi-token standard | ERC-1155 |
| Tokenized vaults | ERC-4626 |
| Access control | `Ownable`, `AccessControl` |
| Utilities | `SafeERC20`, cryptography and other helpers |
| Governance | Voting-related extensions |

Ethereum applications often need to implement standards that many other applications also use. OpenZeppelin provides reusable implementations so developers can build on established components rather than creating a new implementation for every project.

For example, an ERC-20 token needs common behavior such as balances, transfers, allowances, and standard events. OpenZeppelin's `ERC20` contract implements the core behavior. A project can inherit from it and define its own token-supply mechanism and application-specific rules.

**Important:** OpenZeppelin is a library, not a complete application. It provides building blocks; the developer remains responsible for choosing and integrating them correctly.

---

## 3. Installing OpenZeppelin Contracts in Foundry

Run the following command from the root directory of your Foundry project:

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

Foundry installs the dependency under `lib/`. A project may then look like this:

```text
my-project/
├── lib/
│   ├── forge-std/
│   └── openzeppelin-contracts/
├── src/
├── test/
├── script/
└── foundry.toml
```

The exact contents of `lib/` depend on the dependencies installed in the project.

### What does `forge install` do?

The command adds an external dependency to a Foundry project. Git-based dependencies are commonly integrated through Git submodules, allowing the project to track a specific dependency revision.

Inspect the installed submodules with:

```bash
git submodule status
```

The OpenZeppelin Solidity sources are located under:

```text
lib/openzeppelin-contracts/contracts/
```

### Version management

For reproducible builds, avoid relying blindly on an unspecified moving branch. Choose and record a release or commit compatible with your compiler and project requirements. Review release notes and compatibility information before upgrading.

Useful commands include:

```bash
forge install OpenZeppelin/openzeppelin-contracts
forge update
```

Be deliberate with updates: inspect dependency changes, review release notes, compile, and run the test suite.

---

## 4. Understanding Foundry's `lib` Directory

Foundry projects commonly use these directories:

| Directory | Purpose |
|---|---|
| `src/` | Solidity source contracts |
| `test/` | Solidity tests |
| `script/` | Deployment and interaction scripts |
| `lib/` | External dependencies |
| `out/` | Compiler artifacts generated by Foundry |
| `cache/` | Build cache data |

The setting below tells Foundry that dependencies can be found under `lib`:

```toml
libs = ["lib"]
```

Installing a library and resolving its Solidity import paths are related but separate tasks. Import remappings tell the compiler how a package-style import maps to a real directory.

---

## 5. What Are Import Remappings?

An import remapping maps an import prefix to a directory in the project.

Consider this import:

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

The actual installed file is located at:

```text
lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol
```

A remapping connects the two paths:

```text
@openzeppelin/contracts/  →  lib/openzeppelin-contracts/contracts/
```

The general form is:

```text
import-prefix=target-directory
```

For OpenZeppelin:

```text
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
```

When the compiler encounters an import beginning with `@openzeppelin/contracts/`, Foundry replaces that prefix with the configured target directory and resolves the remaining path.

### Why use remappings?

Without a remapping, the compiler may not know how to resolve package-style imports. A remapping avoids long relative paths such as:

```solidity
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
```

Package-style imports are easier to read and maintain, especially when a project contains many contracts and dependencies.

---

## 6. Configuring Remappings in `foundry.toml`

Foundry uses `foundry.toml` as its project configuration file. It can define source directories, output directories, library directories, compiler settings, remappings, and more.

A configuration for this lesson:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

remappings = [
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"
]

# See more config options:
# https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md#all-options
```

### Understanding each setting

- **`[profile.default]`** defines the default Foundry configuration profile.
- **`src = "src"`** specifies the directory containing Solidity source files.
- **`out = "out"`** specifies where Foundry writes compiler output and generated artifacts.
- **`libs = ["lib"]`** tells Foundry where to look for dependencies.
- **`remappings = [...]`** defines import-prefix mappings used to resolve dependency imports.

The trailing slash in the mapping makes the package prefix and target directory boundaries explicit:

```toml
"@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"
```

### Alternative: `remappings.txt`

Foundry also supports a `remappings.txt` file at the project root. The equivalent entry is:

```text
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
```

Use one clear source of remapping configuration for a given mapping rather than maintaining conflicting definitions.

### Verify the configuration

Display Foundry's resolved configuration:

```bash
forge config
```

Compile the project:

```bash
forge build
```

If the dependency location and remapping are correct, Foundry should resolve the OpenZeppelin import.

---

## 7. Importing an OpenZeppelin Contract

After installing the dependency and configuring the remapping, import the required source file:

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

Solidity also supports named imports:

```solidity
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

Named imports make the imported symbol explicit and are convenient when a file needs only a few symbols from another source file.

### Importing is not the same as using

This makes `ERC20` available in the source file:

```solidity
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyContract {
    // ERC20 is imported, but this contract does not inherit from it.
}
```

The import does not automatically add ERC-20 behavior to `MyContract`.

To inherit from OpenZeppelin's implementation, use Solidity inheritance:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}
```

In this example:

- `MyToken is ERC20` means `MyToken` inherits from OpenZeppelin's ERC-20 implementation.
- `ERC20("My Token", "MTK")` initializes the token name and symbol through the parent constructor.
- `_mint(...)` creates the initial supply and assigns it to the deployer.
- OpenZeppelin's ERC20 implementation uses 18 decimals by default.

This is a minimal educational example. Real token supply, permissions, and distribution rules must be designed for the application's requirements.

---

## 8. Understanding the ERC-20 Standard

ERC-20 is a standard interface for fungible tokens on Ethereum-compatible networks.

Fungible means that each unit of a token is interchangeable with another unit of the same token. ERC-20 defines common operations and events so wallets, decentralized applications, exchanges, and other contracts can interact with tokens consistently.

Important ERC-20 functions include:

| Function | Purpose |
|---|---|
| `totalSupply()` | Returns the total token supply. |
| `balanceOf(address)` | Returns an account's token balance. |
| `transfer(address, uint256)` | Transfers tokens from the caller to another account. |
| `approve(address, uint256)` | Sets an allowance for a spender. |
| `allowance(address, address)` | Returns the remaining allowance. |
| `transferFrom(address, address, uint256)` | Transfers tokens using an allowance. |

Common events:

- `Transfer`: emitted when tokens are transferred, including minting and burning.
- `Approval`: emitted when an allowance is approved or changed.

### ERC-20 decimals

ERC-20 balances are stored as integers. `decimals()` tells applications how to display those integer amounts.

OpenZeppelin's ERC20 implementation uses 18 decimals by default:

```text
1 token = 10^18 base units
```

Decimals affect representation and user interfaces; Solidity still performs integer arithmetic.

---

## 9. Applying the Import in the Vault Example

The lesson's `Vault.sol` includes:

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

The contract itself:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vault {
    // Balance mapping
    mapping(address => uint256) public balances;

    // Deposit Ether
    function deposit() external payable {
        require(msg.value > 0, "Insufficient amount");
        balances[msg.sender] += msg.value;
    }

    // Withdraw Ether
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdraw failed");
    }

    // Get the caller's balance
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}
```

### What does this contract currently do?

The `Vault` tracks Ether deposits in a mapping:

```solidity
mapping(address => uint256) public balances;
```

- `deposit()` accepts Ether and increases the caller's recorded balance.
- `withdraw(uint256 amount)` checks the caller's recorded balance, decreases it, and attempts to send Ether to the caller.
- `getBalance()` returns the recorded balance of the caller.

### Does this Vault use ERC-20?

Not yet.

Although `ERC20.sol` is imported, `Vault` does not inherit from `ERC20` and does not call any ERC-20 functions. Its current accounting is based on Ether (`msg.value` and Ether transfers), not ERC-20 tokens.

Remember the distinction:

- **Import:** makes a contract or symbol available in the source file.
- **Inheritance:** brings parent contract functionality into a derived contract.
- **Composition / external interaction:** allows a contract to hold a reference to or call another contract without inheriting from it.

If a future vault is intended to deposit and withdraw ERC-20 assets, it will need to interact with an ERC-20 token contract, commonly through the `IERC20` interface and carefully handled token transfers. That is a different design from this Ether-only example.

---

## 10. Dependency and Security Best Practices

Third-party libraries can reduce implementation work, but they also become part of the project's dependency and security surface.

1. **Use official sources.** Install dependencies from the maintainers' official repositories and documentation.
2. **Choose versions deliberately.** Pin or record a known release or commit when reproducible builds matter.
3. **Review upgrades.** Read release notes and inspect dependency changes before updating.
4. **Avoid casually modifying library code.** Prefer using published implementations as intended. If customization is necessary, understand and document the changes.
5. **Test your integration.** A trusted library cannot guarantee that your contract uses it correctly.
6. **Understand inherited behavior.** Review constructors, access control, overrides, external calls, and state changes.
7. **Keep secrets out of source control.** Never commit private keys or sensitive environment values.
8. **Treat audits as scoped evidence, not a guarantee.** An audited library does not make every contract that imports it secure.

For production systems, review the exact dependency version, compiler compatibility, deployment configuration, and security assumptions of the complete application.

---

## 11. Useful Foundry Commands

| Command | Purpose |
|---|---|
| `forge install OpenZeppelin/openzeppelin-contracts` | Install OpenZeppelin Contracts. |
| `forge build` | Compile the project and resolve imports. |
| `forge test` | Run the project's tests. |
| `forge config` | Display the resolved Foundry configuration. |
| `git submodule status` | Inspect Git submodule revisions. |
| `forge update` | Update installed dependencies. |

After updating dependencies, inspect the changes and run the project's build and tests again.

---

## 12. Key Takeaways

- Third-party libraries provide reusable components for smart contract development.
- OpenZeppelin Contracts provides implementations and utilities including ERC-20, ERC-721, ERC-1155, access control, and more.
- Foundry dependencies are commonly stored in `lib/`.
- `forge install` adds a dependency to a Foundry project.
- Import remappings connect package-style Solidity imports to actual directories.
- `foundry.toml` can define remappings under the selected profile.
- Importing a contract does not automatically mean the current contract inherits from or uses it.
- ERC-20 is a fungible-token standard; it is different from Ether accounting.
- Dependency selection, version management, testing, and security review remain the application's responsibility.

---

## References

1. [OpenZeppelin Contracts – Documentation](https://docs.openzeppelin.com/contracts/5.x/)
2. [OpenZeppelin – ERC-20 Guide](https://docs.openzeppelin.com/contracts/5.x/erc20)
3. [OpenZeppelin – ERC-20 API Reference](https://docs.openzeppelin.com/contracts/5.x/api/token/erc20)
4. [OpenZeppelin – Extending Contracts](https://docs.openzeppelin.com/contracts/5.x/extending-contracts)
5. [Foundry – Configuration](https://www.getfoundry.sh/config/)
6. [Foundry – Book](https://book.getfoundry.sh/)
7. [OpenZeppelin Contracts – GitHub Repository](https://github.com/OpenZeppelin/openzeppelin-contracts)

---

*This guide covers installing and importing a third-party Solidity dependency with Foundry, using OpenZeppelin Contracts as the example.*
