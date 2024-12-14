# BoN Smart Contracts

This repository contains the smart contracts for the BoN project, created for the [Shapecraft Hackathon](https://university.alchemy.com/hackathons/shapecraft).

## Overview

These smart contracts enable the creation of dynamic NFTs with the concept of **Root Tokens** and **Child Tokens**. Depending on the implementation, certain metadata manipulation operations are restricted to either the Root Token owner or the Child Token owner.

### Token Structure

- **Root Token:** Represents a Business Token.
- **Child Token:** Represents a Loyalty Card.

**Functionality:**

- Business Tokens can mint Loyalty Cards, which remain permanently associated with the minting Business Token.
- Only the wallet owning the Business Token can gift points to its associated Loyalty Cards.
- Only the Loyalty Card owner can redeem points.

### Services

Two main services are implemented:

1. **Loyalty Service**

   - Mint Loyalty Cards.
   - Gift points to Loyalty Cards.
   - Associate collections as point multipliers (e.g., Shapecraft keys in the demo).

2. **Partner NFT Service**
   - Receive Partner NFTs from any wallet.
   - Distribute Partner NFTs to Loyalty Card holders or other wallets.

## Requirements

- Install **Node.js** and **npm**.

## Installation

Run the following command to install the required dependencies:

```bash
npm install
```

## Running Tests

Execute all tests using:

```bash
npx hardhat test test/AllTests.js
```

## Deployment

To deploy the smart contracts and associate them with the Gasback service:

```bash
npx hardhat ignition deploy ignition/modules/GasbackService.js --network <network_id>
```

### Notes:

- The Gasback service module deploys a specific smart contract that:
  - Mints a Gasback token.
  - Associates it with every interactable contract on BoN.
  - Sends the token to the user executing the deployment.

## Frontend

The frontend is built using the low-code platform [OutSystems](https://www.outsystems.com/forge/component-overview/20550/businessonchain-o11).

### Additional Tools and Modules

We have created tools and modules to aid in development on OutSystems and interaction with it. You can find all components [here](https://www.outsystems.com/forge/).

### Running the Frontend in Your Environment

To run the frontend after deploying the smart contracts:

1. Navigate to the `scripts` directory:

   ```bash
   cd scripts
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Create a `.env` file with the following:

   ```env
   OS_ADMIN=<your_os_user>
   OS_ADMIN_PASS=<your_os_user_pass>
   OS_HOST=<os_server_endpoint>
   ```

4. Run the following command:
   ```bash
   node admin/set_smart_contract.js -all <network_id>
   ```

## Contract Verification

We have included configuration to verify contracts on the Shapecraft mainnet using Hardhat:

```bash
npx hardhat verify --network shape-mainnet <contract_address> <constructor_params>
```

Example:

```bash
npx hardhat verify --network shape-mainnet 0x31a539F4A4480f6c0dDABBfA3D58e7FB9608d462 0x5d84B43d662CB1787716D4804A6164Efc135FfB6
```
