// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title SuperwhitelistERC20
 * @author opnxj
 * @dev The SuperwhitelistERC20 contract is an abstract contract that extends the ERC20 token functionality.
 * It adds the ability to manage a blacklist and a superwhitelist, allowing certain addresses to be excluded from the blacklist.
 * The owner can assign a blacklister, who is responsible for managing the blacklist and adding addresses to it.
 * Addresses on the superwhitelist are immune from being blacklisted and have additional privileges.
 */
abstract contract SuperwhitelistERC20 is ERC20, Ownable {
    address public blacklister;
    mapping(address => bool) public blacklist;
    mapping(address => bool) public superwhitelist;

    event BlacklisterSet(address indexed addr);
    event BlacklistAdded(address indexed addr);
    event BlacklistRemoved(address indexed addr);
    event SuperwhitelistAdded(address indexed addr);

    modifier notBlacklisted(address addr) {
        require(!blacklist[addr], "Address is blacklisted");
        _;
    }

    modifier onlyBlacklister() {
        require(
            msg.sender == blacklister,
            "Only the blacklister can call this function"
        );
        _;
    }

    modifier onlySuperwhitelister() {
        require(
            msg.sender == owner() || superwhitelist[msg.sender],
            "Only the owner or superwhitelisted can call this function"
        );
        _;
    }

    /**
     * @notice Initializes the SuperwhitelistERC20 contract.
     * @dev This constructor is called when deploying the contract. It sets the 
            initial values of the ERC20 token (name, symbol, and decimals) using the 
            provided parameters. The deployer of the contract becomes the blacklister.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param decimals The number of decimals used for token representation.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) ERC20(name, symbol, decimals) {
        blacklister = msg.sender;
    }

    /**
     * @notice Sets the address assigned to the blacklister role.
     * @dev Only the contract owner can call this function. It updates the blacklister 
            address to the provided address.
     * @param addr The address to assign as the blacklister.
     * Emits a `BlacklisterSet` event on success.
     */
    function setBlacklister(address addr) external onlyOwner {
        blacklister = addr;
        emit BlacklisterSet(addr);
    }

    /**
     * @notice Adds the specified address to the blacklist.
     * @dev Only the blacklister can call this function. The address will be prevented
            from performing transfers if it is on the blacklist. Addresses on the 
            superwhitelist cannot be added to the blacklist using this function.
     * @param addr The address to add to the blacklist.
     * Emits a `BlacklistAdded` event on success.
     */
    function addToBlacklist(address addr) external onlyBlacklister {
        require(
            !superwhitelist[addr],
            "Cannot add superwhitelisted address to the blacklist"
        );
        blacklist[addr] = true;
        emit BlacklistAdded(addr);
    }

    /**
     * @notice Removes the specified address from the blacklist.
     * @dev Internal function used to remove an address from the blacklist. This 
            function should only be called within the contract.
     * @param addr The address to remove from the blacklist.
     * Emits a `BlacklistRemoved` event on success.
     */
    function _removeFromBlacklist(address addr) internal {
        require(blacklist[addr], "Address is not in the blacklist");
        blacklist[addr] = false;
        emit BlacklistRemoved(addr);
    }

    /**
     * @notice Removes the specified address from the blacklist.
     * @dev Only the blacklister can call this function. The address will be allowed 
            to perform transfers again.
     * @param addr The address to remove from the blacklist.
     * Emits a `BlacklistRemoved` event on success.
     */
    function removeFromBlacklist(address addr) external onlyBlacklister {
        _removeFromBlacklist(addr);
    }

    /**
     * @notice Adds the specified address to the superwhitelist.
     * @dev Only the owner can call this function. Once added, the address becomes a 
            superwhitelisted address and cannot be blacklisted. If the address was 
            previously on the blacklist, it will be removed from the blacklist.
     * @param addr The address to add to the superwhitelist.
     * Emits a `BlacklistRemoved` event if the address was previously on the blacklist.
     * Emits a `SuperwhitelistAdded` event on success.
     */
    function addToSuperwhitelist(address addr) external onlySuperwhitelister {
        if (blacklist[addr]) {
            _removeFromBlacklist(addr);
        }
        superwhitelist[addr] = true;
        emit SuperwhitelistAdded(addr);
    }

    /**
     * @notice Transfers a specified amount of tokens from the sender's account to the specified recipient.
     * @dev Overrides the ERC20 `transfer` function. Restricts the transfer if either
            the sender or recipient is blacklisted.
     * @param to The address of the recipient.
     * @param value The amount of tokens to transfer.
     * @return A boolean indicating the success of the transfer.
     */
    function transfer(
        address to,
        uint256 value
    )
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        return super.transfer(to, value);
    }

    /**
     * @notice Transfers a specified amount of tokens from a specified address to the 
               specified recipient, on behalf of the sender.
     * @dev Overrides the ERC20 `transferFrom` function. Restricts the transfer if 
            either the sender, recipient, or `from` address is blacklisted.
     * @param from The address from which to transfer tokens.
     * @param to The address of the recipient.
     * @param value The amount of tokens to transfer.
     * @return A boolean indicating the success of the transfer.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }
}
