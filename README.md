# SuperwhitelistERC20

**SuperwhitelistERC20** is an abstract contract that extends [Solmate's ERC20](https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol) implementation and adds blacklist/superwhitelist functionality. It allows for the management of a superwhitelist, which grants immunity from being blacklisted, and a blacklist, which restricts transfers involving blacklisted addresses.

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
   - The superwhitelist is effectively append-only, meaning addresses cannot be removed from it once added.

6. Removing Addresses from the Blacklist
   - The owner can remove addresses from the blacklist.

## Safety

This is **experimental software** and is provided on an "as is" and "as available" basis.

- There are implicit invariants these contracts expect to hold.
- **You can easily shoot yourself in the foot if you're not careful.**
- You should thoroughly read each contract you plan to use top to bottom.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install opnxj/superwhitelist
```

## Contributing

Contributions to the SuperwhitelistERC20 contract are welcome! If you encounter any issues or have suggestions for improvements, please open an issue on the GitHub repository.

## License

The SuperwhitelistERC20 contract is licensed under the MIT License.
