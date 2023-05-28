# SuperallowlistERC20

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Description

SuperallowlistERC20 is an extension of [LayerZero's OFT](https://github.com/LayerZero-Labs/solidity-examples/blob/5ce17fa2537e8da5adb7534a8584e70affe04ed0/contracts/token/oft/OFT.sol) implementation. It extends the standard denylist functionality to include an append-only "superallowlist", which effectively grants permanent immunity from being denylisted.

## Table of Contents

- [SuperallowlistERC20](#superallowlisterc20)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Key Components](#key-components)
    - [Interacting with the Contract](#interacting-with-the-contract)
      - [Owner Functions](#owner-functions)
      - [Denylister Functions](#denylister-functions)
      - [Superallowlisted Functions](#superallowlisted-functions)
  - [API Reference](#api-reference)
    - [State Variables](#state-variables)
    - [Events](#events)
      - [`DenylisterSet(address addr)`](#denylistersetaddress-addr)
      - [`DenylistAdded(address addr)`](#denylistaddedaddress-addr)
      - [`DenylistRemoved(address addr)`](#denylistremovedaddress-addr)
      - [`SuperallowlistAdded(address addr)`](#superallowlistaddedaddress-addr)
    - [Owner Functions](#owner-functions-1)
      - [`setDenylister(address addr)`](#setdenylisteraddress-addr)
    - [Denylister Functions](#denylister-functions-1)
      - [`addToDenylist(address addr)`](#addtodenylistaddress-addr)
      - [`removeFromDenylist(address addr)`](#removefromdenylistaddress-addr)
    - [Superallowlisted Functions](#superallowlisted-functions-1)
      - [`addToSuperallowlist(address addr)`](#addtosuperallowlistaddress-addr)
    - [ERC20 Functions](#erc20-functions)
      - [`transfer(address to, uint256 value)`](#transferaddress-to-uint256-value)
      - [`transferFrom(address from, address to, uint256 value)`](#transferfromaddress-from-address-to-uint256-value)

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install opnxj/superallowlist
```

## Usage

The `SuperallowlistERC20` contract provides functionalities for managing a denylist and a superallowlist. It allows the owner to set a denylister address which manages the denylist. It also allows the owner to add addresses to the superallowlist, which grants immunity from being denylisted and the ability to add other addresses to the superallowlist.

### Key Components

The following are the key components or entities involved in the `SuperallowlistERC20` contract:

- **Owner**: The owner of the contract has the authority to set the denylister and add users to the superallowlist.

- **Denylister**: The denylister is an explicit role that can be updated by the owner. The denylister is responsible for managing the denylist and has the ability to add or remove addresses from it, as long as the address is not on the superallowlist.

- **Superallowlisted**: The superallowlisted role is implicitly assigned to addresses that are added to the superallowlist. Addresses on the superallowlist can add other addresses to the superallowlist and cannot be denylisted once added.

### Interacting with the Contract

Users can interact with contracts that inherit from `SuperallowlistERC20` through the following methods and functions:

#### Owner Functions

- `setDenylister(address addr)`: This function allows the owner to update the address assigned to the denylister role. Only the owner has permission to call this function.

#### Denylister Functions

- `addToDenylist(address addr)`: This function adds the specified address `addr` to the denylist. The address will be prevented from performing transfers if it is on the denylist. However, addresses on the superallowlist cannot be added to the denylist using this function.

- `removeFromDenylist(address addr)`: This function removes the specified address `addr` from the denylist, allowing it to perform transfers again.

#### Superallowlisted Functions

Addresses on the superallowlist have the following capabilities:

- `addToSuperallowlist(address addr)`: This function adds the specified address `addr` to the superallowlist. Once added, the address becomes a superallowlisted address and cannot be denylisted. If the address was previously on the denylist, it will be removed from the denylist.

## API Reference

### State Variables

`SuperallowlistERC20` defines the following state variables:

- `address public denylister`: The address assigned to the denylister role.
- `mapping(address => bool) public denylist`: Mapping to store denylisted addresses.
- `mapping(address => bool) public superallowlist`: Mapping to store superallowlisted addresses.

### Events

The `SuperallowlistERC20` contract emits the following events:

#### `DenylisterSet(address addr)`

Emitted when the denylister address is updated.

- Parameters:
  - `addr`: The address assigned to the denylister role.

#### `DenylistAdded(address addr)`

Emitted when an address is added to the denylist.

- Parameters:
  - `addr`: The address that was added to the denylist.

#### `DenylistRemoved(address addr)`

Emitted when an address is removed from the denylist.

- Parameters:
  - `addr`: The address that was removed from the denylist.

#### `SuperallowlistAdded(address addr)`

Emitted when an address is added to the superallowlist.

- Parameters:
  - `addr`: The address that was added to the superallowlist.

### Owner Functions

#### `setDenylister(address addr)`

Allows the owner to update the address assigned to the denylister role.

- Parameters:
  - `addr`: The address to assign as the denylister.

### Denylister Functions

#### `addToDenylist(address addr)`

Adds the specified address to the denylist, preventing it from performing transfers.

- Parameters:
  - `addr`: The address to add to the denylist.

#### `removeFromDenylist(address addr)`

Removes the specified address from the denylist, allowing it to perform transfers again.

- Parameters:
  - `addr`: The address to remove from the denylist.

### Superallowlisted Functions

#### `addToSuperallowlist(address addr)`

Adds the specified address to the superallowlist.

- Parameters:
  - `addr`: The address to add to the superallowlist.

### ERC20 Functions

`SuperallowlistERC20` contract overrides the following functions from the OFT's underlying ERC20 implementation:

#### `transfer(address to, uint256 value)`

Transfers a specified amount of tokens from the sender's account to the specified recipient.

- Parameters:
  - `to`: The address of the recipient.
  - `value`: The amount of tokens to transfer.
- Modifiers: Restricts transfer if either the sender or recipient is denylisted.
- Returns: A boolean indicating the success of the transfer.

#### `transferFrom(address from, address to, uint256 value)`

Transfers a specified amount of tokens from a specified address to the specified recipient, on behalf of the sender.

- Parameters:
  - `from`: The address from which to transfer tokens.
  - `to`: The address of the recipient.
  - `value`: The amount of tokens to transfer.
- Modifiers: Restricts transfer if either the sender, recipient, or `from` address is denylisted.
- Returns: A boolean indicating the success of the transfer.
