# ERC-20 with Superwhitelist Functionality

## Overview

This repo contains the design and implementation of an ERC-20 token with blacklist and "superwhitelist" functionality. The contract allows for the management of a blacklist and a superwhitelist, with transfers being restricted based on those lists. The contract also includes an owner role that's responsible for managing the blacklist and superwhitelist, while addresses on the superwhitelist have immunity from being blacklisted.

## Features

1. Blacklist and Superwhitelist Mappings

   - Two mappings: `blacklist` and `superwhitelist`.
   - The `blacklist` mapping stores addresses that are not allowed to send or receive transfers.
   - The `superwhitelist` mapping stores addresses that are exempt from being added to the blacklist.

2. Transfer Restrictions

   - Before allowing a transfer, check if the sender or recipient is on the blacklist.
   - If either the sender or recipient is on the blacklist, revert the transfer to prevent it from being executed.

3. Owner Role

   - The contract designates an admin role that owns the ERC-20 token contract.
   - The owner has the authority to add/remove to the blacklist and add to the append-only superwhitelist.

4. Adding Addresses to the Blacklist

   - The owner can add addresses to the blacklist.
   - Before adding an address to the blacklist, check if it is on the superwhitelist.
   - If the address is found on the superwhitelist, revert the contract call to prevent addition.

5. Adding Addresses to the Superwhitelist

   - The contract includes a function to add addresses to the superwhitelist.
   - The superwhitelist should be effectively append-only, meaning addresses cannot be removed from it once added.

6. Removing Addresses from the Blacklist
   - The owner can remove addresses from the blacklist.

## Implementation Details

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SuperwhitelistERC20 {
    mapping(address => bool) public blacklist;
    mapping(address => bool) public superwhitelist;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    modifier notSuperwhitelisted(address _address) {
        require(!superwhitelist[_address], "Address is in the superwhitelist");
        _;
    }

    modifier notBlacklisted(address _address) {
        require(!blacklist[_address], "Address is blacklisted");
        _;
    }

    function addToBlacklist(address _address) external onlyOwner notSuperwhitelisted(_address) {
        blacklist[_address] = true;
    }

    function addToSuperwhitelist(address _address) external onlyOwner {
        superwhitelist[_address] = true;
    }

    function removeFromBlacklist(address _address) external onlyOwner {
        blacklist[_address] = false;
    }

    function transfer(address _to, uint256 _amount) external notBlacklisted(msg.sender) notBlacklisted(_to) {
        // Perform transfer logic
    }

    // ...
}
```
