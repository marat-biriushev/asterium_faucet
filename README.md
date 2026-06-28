# Solidity Learning Journey – Faucet Contract (Foundry)

## Overview

This project documents my first end-to-end experience developing, deploying, and interacting with a Solidity smart contract using **Foundry** on the **Ethereum Sepolia** test network.

---

# Environment

## Tools

* Solidity 0.8.26
* Foundry (`forge`, `cast`)
* Ethereum Sepolia Testnet
* Public RPC endpoint

```text
https://ethereum-sepolia-rpc.publicnode.com
```

---

# Wallet Management

Instead of exposing a private key in a `.env` file, I used a **Foundry keystore**.

List wallets:

```bash
cast wallet list
```

Get wallet address:

```bash
cast wallet address --account example
```

Output:

```text
0x35D6B6e072077111498dF77681BdE12AB364e18D
```

Benefits of using a keystore:

* Private key remains encrypted.
* Password is requested only when signing transactions.
* No secrets stored in project files.

---

# Project Structure

```text
faucet/
│
├── src/
│   └── Faucet.sol
│
├── script/
│   └── Faucet.s.sol
│
├── test/
│
├── lib/
│
└── foundry.toml
```

---

# Faucet Contract

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;

contract Faucet {

    function withdraw(
        uint _withdrawAmount,
        address payable _to
    ) public {

        require(_withdrawAmount <= 0.1 ether);

        _to.transfer(_withdrawAmount);
    }

    receive() external payable {}
}
```

## Contract Features

* Accept ETH transfers.
* Allow anyone to withdraw up to **0.1 ETH**.
* Transfer ETH from the contract balance.

---

# Build

Compile the project:

```bash
forge build
```

Expected output:

```text
Compiler run successful!
```

---

# Deployment Script

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/Faucet.sol";

contract FaucetScript is Script {

    function run() external returns (Faucet faucet) {

        vm.startBroadcast();

        faucet = new Faucet();

        vm.stopBroadcast();
    }
}
```

### Explanation

| Statement             | Purpose                         |
| --------------------- | ------------------------------- |
| `vm.startBroadcast()` | Start sending real transactions |
| `new Faucet()`        | Deploy the smart contract       |
| `vm.stopBroadcast()`  | Stop broadcasting               |

---

# Dry Run

Simulate deployment without spending ETH.

```bash
forge script script/Faucet.s.sol \
    --account example \
    --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

Dry run:

* Executes locally
* Estimates gas
* Does **not** broadcast a transaction

---

# Deploy to Sepolia

```bash
forge script script/Faucet.s.sol \
    --account example \
    --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
    --broadcast
```

Deployment result:

```text
Contract Address:
0x46ef5804415C14866b0403C3b78505cd53b0306e
```

---

# Check Contract Balance

```bash
cast balance \
0x46ef5804415C14866b0403C3b78505cd53b0306e \
--rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

Initial balance:

```text
0
```

---

# Send ETH to the Contract

```bash
cast send \
0x46ef5804415C14866b0403C3b78505cd53b0306e \
--value 0.1ether \
--account example \
--rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

Verify:

```bash
cast balance \
0x46ef5804415C14866b0403C3b78505cd53b0306e \
--rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

Output:

```text
100000000000000000
```

which equals

```text
0.1 ETH
```

---

# Call withdraw()

Withdraw **0.05 ETH** back to the wallet.

```bash
cast send \
0x46ef5804415C14866b0403C3b78505cd53b0306e \
"withdraw(uint256,address)" \
0.05ether \
0x35D6B6e072077111498dF77681BdE12AB364e18D \
--account example \
--rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

Verify balances:

```bash
cast balance 0x46ef5804415C14866b0403C3b78505cd53b0306e \
--rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

Contract balance:

```text
0.05 ETH
```

Wallet balance increased by approximately **0.05 ETH** (minus gas fees).

---

# Understanding ABI

ABI stands for:

> **Application Binary Interface**

It defines how Solidity function calls are encoded into bytes that the EVM understands.

Function:

```solidity
withdraw(uint256,address)
```

---

# Function Selector

Each function has a unique **4-byte selector**.

It is calculated as:

```text
keccak256("withdraw(uint256,address)")
```

The first 4 bytes of the hash become the selector.

---

# Calldata

Ethereum never sends text like:

```solidity
withdraw(0.05 ether, address)
```

Instead, it sends binary data.

Generate calldata:

```bash
cast calldata \
"withdraw(uint256,address)" \
50000000000000000 \
0x35D6B6e072077111498dF77681BdE12AB364e18D
```

Output:

```text
0x00f714ce
00000000000000000000000000000000000000000000000000b1a2bc2ec50000
00000000000000000000000035d6b6e072077111498df77681bde12ab364e18d
```

Structure:

```text
+------------+----------------------+----------------------+
| 4 bytes    | 32 bytes             | 32 bytes             |
+------------+----------------------+----------------------+
| Selector   | uint256 amount       | address              |
+------------+----------------------+----------------------+
```

---

# EVM Execution Flow

```text
User
    │
    ▼
cast send
    │
    ▼
ABI Encoding
    │
    ▼
Calldata
    │
    ▼
Ethereum Transaction
    │
    ▼
EVM
    │
    ▼
Read Function Selector
    │
    ▼
Decode Arguments
    │
    ▼
Execute withdraw()
```

---

# EVM Memory Areas

## Storage

Persistent contract state.

## Memory

Temporary memory during execution.

## Stack

Execution stack.

## Calldata

Read-only input data provided by the transaction.

---

# Commands Learned

Compile:

```bash
forge build
```

Deploy:

```bash
forge script
```

Check balance:

```bash
cast balance
```

Send transaction:

```bash
cast send
```

Generate calldata:

```bash
cast calldata
```

Display wallet address:

```bash
cast wallet address --account example
```

---

# Key Concepts Learned

* Solidity contract structure
* Deploying contracts with Foundry
* Foundry keystore
* Ethereum transactions
* Gas and gas fees
* Wei vs Ether
* `receive()`
* `transfer()`
* ABI (Application Binary Interface)
* Function selector
* Calldata
* EVM execution flow

---

# Next Topics

* State variables
* Storage layout
* `msg.sender`
* `msg.value`
* Events (`emit`)
* `view` and `pure`
* `call`, `delegatecall`, `staticcall`
* Arrays
* Mappings
* Structs
* Modifiers
* Inheritance
* ERC-20 implementation
* Unit testing with Foundry
* Reading contract state with `cast call`



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
# asterium_faucet
