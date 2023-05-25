# SuperwhitelistERC20

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Description

SuperwhitelistERC20 is an extension of [Solmate's ERC20](https://github.com/transmissions11/solmate/blob/2001af43aedb46fdc2335d2a7714fb2dae7cfcd1/src/tokens/ERC20.sol) implementation. It extends the standard blacklist functionality to include an append-only "superwhitelist", which effectively grants permanent immunity from being blacklisted.

## Table of Contents

- [SuperwhitelistERC20](#superwhitelisterc20)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Key Components](#key-components)
    - [Interacting with the Contract](#interacting-with-the-contract)
      - [Owner Functions](#owner-functions)
      - [Blacklister Functions](#blacklister-functions)
      - [Superwhitelisted Functions](#superwhitelisted-functions)
  - [API Reference](#api-reference)
    - [State Variables](#state-variables)
    - [Events](#events)
      - [`BlacklisterSet(address addr)`](#blacklistersetaddress-addr)
      - [`BlacklistAdded(address addr)`](#blacklistaddedaddress-addr)
      - [`BlacklistRemoved(address addr)`](#blacklistremovedaddress-addr)
      - [`SuperwhitelistAdded(address addr)`](#superwhitelistaddedaddress-addr)
    - [Owner Functions](#owner-functions-1)
      - [`setBlacklister(address addr)`](#setblacklisteraddress-addr)
    - [Blacklister Functions](#blacklister-functions-1)
      - [`addToBlacklist(address addr)`](#addtoblacklistaddress-addr)
      - [`removeFromBlacklist(address addr)`](#removefromblacklistaddress-addr)
    - [Superwhitelisted Functions](#superwhitelisted-functions-1)
      - [`addToSuperwhitelist(address addr)`](#addtosuperwhitelistaddress-addr)
    - [ERC20 Functions](#erc20-functions)
      - [`transfer(address to, uint256 value)`](#transferaddress-to-uint256-value)
      - [`transferFrom(address from, address to, uint256 value)`](#transferfromaddress-from-address-to-uint256-value)

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install opnxj/superwhitelist
```

## Usage

The `SuperwhitelistERC20` contract provides functionalities for managing a blacklist and a superwhitelist. It allows the owner to set a blacklister address which manages the blacklist. It also allows the owner to add addresses to the superwhitelist, which grants immunity from being blacklisted and the ability to add other addresses to the superwhitelist.

### Key Components

The following are the key components or entities involved in the `SuperwhitelistERC20` contract:

- **Owner**: The owner of the contract has the authority to set the blacklister and add users to the superwhitelist.

- **Blacklister**: The blacklister is an explicit role that can be updated by the owner. The blacklister is responsible for managing the blacklist and has the ability to add or remove addresses from it, as long as the address is not on the superwhitelist.

- **Superwhitelisted**: The superwhitelisted role is implicitly assigned to addresses that are added to the superwhitelist. Addresses on the superwhitelist can add other addresses to the superwhitelist and cannot be blacklisted once added.

### Interacting with the Contract

Users can interact with contracts that inherit from `SuperwhitelistERC20` through the following methods and functions:

#### Owner Functions

- `setBlacklister(address addr)`: This function allows the owner to update the address assigned to the blacklister role. Only the owner has permission to call this function.

#### Blacklister Functions

- `addToBlacklist(address addr)`: This function adds the specified address `addr` to the blacklist. The address will be prevented from performing transfers if it is on the blacklist. However, addresses on the superwhitelist cannot be added to the blacklist using this function.

- `removeFromBlacklist(address addr)`: This function removes the specified address `addr` from the blacklist, allowing it to perform transfers again.

#### Superwhitelisted Functions

Addresses on the superwhitelist have the following capabilities:

- `addToSuperwhitelist(address addr)`: This function adds the specified address `addr` to the superwhitelist. Once added, the address becomes a superwhitelisted address and cannot be blacklisted. If the address was previously on the blacklist, it will be removed from the blacklist.

## API Reference

### State Variables

`SuperwhitelistERC20` defines the following state variables:

- `address public blacklister`: The address assigned to the blacklister role.
- `mapping(address => bool) public blacklist`: Mapping to store blacklisted addresses.
- `mapping(address => bool) public superwhitelist`: Mapping to store superwhitelisted addresses.

### Events

The `SuperwhitelistERC20` contract emits the following events:

#### `BlacklisterSet(address addr)`

Emitted when the blacklister address is updated.

- Parameters:
  - `addr`: The address assigned to the blacklister role.

#### `BlacklistAdded(address addr)`

Emitted when an address is added to the blacklist.

- Parameters:
  - `addr`: The address that was added to the blacklist.

#### `BlacklistRemoved(address addr)`

Emitted when an address is removed from the blacklist.

- Parameters:
  - `addr`: The address that was removed from the blacklist.

#### `SuperwhitelistAdded(address addr)`

Emitted when an address is added to the superwhitelist.

- Parameters:
  - `addr`: The address that was added to the superwhitelist.

### Owner Functions

#### `setBlacklister(address addr)`

Allows the owner to update the address assigned to the blacklister role.

- Parameters:
  - `addr`: The address to assign as the blacklister.

### Blacklister Functions

#### `addToBlacklist(address addr)`

Adds the specified address to the blacklist, preventing it from performing transfers.

- Parameters:
  - `addr`: The address to add to the blacklist.

#### `removeFromBlacklist(address addr)`

Removes the specified address from the blacklist, allowing it to perform transfers again.

- Parameters:
  - `addr`: The address to remove from the blacklist.

### Superwhitelisted Functions

#### `addToSuperwhitelist(address addr)`

Adds the specified address to the superwhitelist.

- Parameters:
  - `addr`: The address to add to the superwhitelist.

### ERC20 Functions

`SuperwhitelistERC20` contract overrides the following functions from the Solmate ERC20 implementation:

#### `transfer(address to, uint256 value)`

Transfers a specified amount of tokens from the sender's account to the specified recipient.

- Parameters:
  - `to`: The address of the recipient.
  - `value`: The amount of tokens to transfer.
- Modifiers: Restricts transfer if either the sender or recipient is blacklisted.
- Returns: A boolean indicating the success of the transfer.

#### `transferFrom(address from, address to, uint256 value)`

Transfers a specified amount of tokens from a specified address to the specified recipient, on behalf of the sender.

- Parameters:
  - `from`: The address from which to transfer tokens.
  - `to`: The address of the recipient.
  - `value`: The amount of tokens to transfer.
- Modifiers: Restricts transfer if either the sender, recipient, or `from` address is blacklisted.
- Returns: A boolean indicating the success of the transfer.
