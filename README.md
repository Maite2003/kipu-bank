# KipuBank 🏦

A simple and secure Ethereum smart contract that functions as a decentralized bank, allowing users to deposit and withdraw Ether with configurable limits and capacity constraints.

## 📋 Overview

KipuBank is a Solidity smart contract designed to simulate basic banking operations on the Ethereum blockchain. It provides secure deposit and withdrawal functionality with built-in safeguards and limitations.

### Key Features

- 💰 **Deposit Ether**: Users can deposit Ether through multiple methods
- 🏧 **Withdraw Ether**: Secure withdrawals with threshold limits
- 🔒 **Security Controls**: Built-in validations and error handling
- 📊 **Balance Tracking**: Individual user balance management
- 🛡️ **Capacity Limits**: Maximum bank capacity to prevent overflow
- 📈 **Statistics**: Track total deposits and withdrawals

## 🏗️ Contract Architecture

### State Variables

- `i_threshold`: Maximum amount allowed for single withdrawal (immutable)
- `i_bankCap`: Maximum total capacity of the bank (immutable)
- `s_numberOfDeposits`: Counter of total deposits made
- `s_numberOfWithdrawals`: Counter of total withdrawals made
- `s_balances`: Mapping of user addresses to their balances

### Events

- `KipuBank_Deposit(address user, uint256 amount)`: Emitted on deposits
- `KipuBank_Withdrawal(address user, uint256 amount)`: Emitted on withdrawals

### Custom Errors

- `KipuBank_ZeroValue()`: When zero value is provided
- `KipuBank_InsufficientBalance(uint256 requestedAmount)`: When user has insufficient balance
- `KipuBank_ExceedsLimit(uint256 requestedAmount)`: When withdrawal exceeds threshold
- `KipuBank_InsufficientCapacity(uint256 requestedAmount, uint256 excess)`: When deposit exceeds bank capacity
- `KipuBank_TransferFailed(address user, uint256 amount)`: When Ether transfer fails

## 🚀 Deployment

### Prerequisites

- MetaMask or similar Ethereum wallet
- Test ETH (for testnet deployment)
- Access to [Remix IDE](https://remix.ethereum.org/)

### Using Remix IDE

1. **Open Remix**
   - Go to [https://remix.ethereum.org/](https://remix.ethereum.org/)
   - Create a new file called `KipuBank.sol`

2. **Copy the Contract**
   - Copy the entire contract code from `contracts/kipuBank.sol`
   - Paste it into your new file in Remix

3. **Compile the Contract**
   - Go to the "Solidity Compiler" tab (🔧 icon)
   - Select compiler version `0.8.26`
   - Click "Compile KipuBank.sol"
   - Verify there are no compilation errors

4. **Deploy the Contract**
   - Go to the "Deploy & Run Transactions" tab (📤 icon)
   - Select your environment:
     - **Remix VM**: For testing (fake ETH)
     - **Injected Provider**: For real networks via MetaMask
   
5. **Set Constructor Parameters**
   - In the deployment section, you'll see input fields for:
     - `_THRESHOLD`: Maximum withdrawal amount in Wei
       - Example: `1000000000000000000` (1 ETH)
     - `_BANKCAP`: Maximum bank capacity in Wei
       - Example: `100000000000000000000` (100 ETH)

6. **Deploy**
   - Click "Deploy"
   - If using MetaMask, confirm the transaction
   - Wait for deployment confirmation

### Constructor Parameters

When deploying, you need to provide two parameters:

- `_threshold`: Maximum withdrawal amount in Wei (e.g., 1000000000000000000 = 1 ETH)
- `_bankCap`: Maximum bank capacity in Wei (e.g., 100000000000000000000 = 100 ETH)

## 🔧 Interacting with the Contract

### Available Functions

#### Public View Functions

1. **getUserBalance()**
   ```solidity
   function getUserBalance() public view returns (uint256 balance)
   ```
   - Returns the caller's available balance for withdrawal

2. **getThreshold()**
   ```solidity
   function getThreshold() public view returns (uint256 threshold)
   ```
   - Returns the maximum withdrawal threshold

#### Public Functions

1. **deposit()**
   ```solidity
   function deposit() external payable
   ```
   - Explicitly deposit Ether to the bank
   - Must send Ether with the transaction

2. **withdraw(uint256 _amount)**
   ```solidity
   function withdraw(uint256 _amount) external
   ```
   - Withdraw specified amount from your balance
   - Amount must not exceed threshold or your balance

#### Special Functions

1. **receive()**
   - Automatically called when Ether is sent directly to the contract
   - Processes the sent Ether as a deposit

2. **fallback()**
   - Called when invalid function calls are made with Ether
   - Also processes the sent Ether as a deposit


## 📄 License

This project is licensed under the MIT License - see the contract SPDX identifier for details.


**⚠️ Disclaimer**: This contract is for educational purposes.