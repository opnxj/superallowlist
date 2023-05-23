# Superwhitelist

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
