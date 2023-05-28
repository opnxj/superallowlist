// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SuperwhitelistERC20} from "../src/SuperwhitelistERC20.sol";

// Test contract that inherits from SuperwhitelistERC20
contract MockSuperwhitelistERC20 is SuperwhitelistERC20 {
    constructor() SuperwhitelistERC20("Superwhitelist", "SWL", address(0)) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract SuperwhitelistERC20Test is Test {
    MockSuperwhitelistERC20 public swlToken;
    address public blacklistedAddr;
    address public superwhitelistedAddr;

    function setUp() public {
        swlToken = new MockSuperwhitelistERC20();

        blacklistedAddr = address(0x1);
        swlToken.addToBlacklist(blacklistedAddr);

        superwhitelistedAddr = address(0x2);
        swlToken.addToSuperwhitelist(superwhitelistedAddr);

        swlToken.mint(blacklistedAddr, 100);
        swlToken.mint(superwhitelistedAddr, 100);
    }

    function testContractDeployment() public {
        // Verify the deployed contract's name, symbol, and decimals
        assertEq(swlToken.name(), "Superwhitelist", "Incorrect token name");
        assertEq(swlToken.symbol(), "SWL", "Incorrect token symbol");
        assertEq(swlToken.decimals(), 18, "Incorrect decimal places");
    }

    function testAddToBlacklist() public {
        assertTrue(
            swlToken.blacklist(blacklistedAddr),
            "Address not added to the blacklist"
        );

        // Verify that normal addresses are able to transfer tokens
        vm.prank(address(superwhitelistedAddr));
        bool success = swlToken.transfer(address(this), 100);
        assertTrue(success, "Normal address was not able to transfer tokens");

        // Verify that the blacklisted address is prevented from transferring tokens
        vm.prank(blacklistedAddr);
        vm.expectRevert("Address is blacklisted");
        success = swlToken.transfer(address(this), 100);
        assertFalse(success, "Blacklisted address was able to transfer tokens");
    }

    function testRemoveFromBlacklist() public {
        assertTrue(
            swlToken.blacklist(blacklistedAddr),
            "Address not added to the blacklist"
        );

        swlToken.removeFromBlacklist(blacklistedAddr);
        assertFalse(
            swlToken.blacklist(blacklistedAddr),
            "Address not removed from the blacklist"
        );

        // Verify that the address can transfer tokens after being removed from the blacklist
        vm.prank(blacklistedAddr);
        bool success = swlToken.transfer(address(this), 100);
        assertTrue(
            success,
            "Address was not able to transfer tokens after removal from the blacklist"
        );
    }

    function testAddToSuperwhitelist() public {
        // Verify that the address is added to the superwhitelist
        assertTrue(
            swlToken.superwhitelist(superwhitelistedAddr),
            "Address not added to the superwhitelist"
        );

        // Verify that the address becomes immune to being blacklisted
        vm.expectRevert("Cannot add superwhitelisted address to the blacklist");
        swlToken.addToBlacklist(superwhitelistedAddr);
        assertFalse(
            swlToken.blacklist(superwhitelistedAddr),
            "Address on the superwhitelist was blacklisted"
        );
    }

    function testAddSuperwhitelistFromBlacklist() public {
        // Add the same address to the superwhitelist
        swlToken.addToSuperwhitelist(blacklistedAddr);

        // Verify that the address is removed from the blacklist
        assertFalse(
            swlToken.blacklist(blacklistedAddr),
            "Address not removed from the blacklist"
        );
    }

    function testSetBlacklisterOnlyOwner() public {
        address newBlacklister = address(0xA);

        // Attempt to set the blacklister address by a non-owner account
        vm.prank(newBlacklister);
        vm.expectRevert("Ownable: caller is not the owner");
        swlToken.setBlacklister(newBlacklister);

        // Verify that the blacklister address remains unchanged
        assertEq(
            swlToken.blacklister(),
            swlToken.owner(),
            "Blacklister address changed incorrectly"
        );

        // Set the blacklister address by the owner account
        vm.prank(swlToken.owner());
        swlToken.setBlacklister(newBlacklister);

        // Verify that the blacklister address is updated
        assertEq(
            swlToken.blacklister(),
            newBlacklister,
            "Blacklister address not updated"
        );
    }

    function testAddToBlacklistOnlyBlacklister() public {
        address addressToAdd = address(0xB);

        // Attempt to add an address to the blacklist by a non-blacklister account
        vm.prank(addressToAdd);
        vm.expectRevert("Only the blacklister can call this function");
        swlToken.addToBlacklist(addressToAdd);

        // Verify that the address is not added to the blacklist
        assertFalse(
            swlToken.blacklist(addressToAdd),
            "Address added to the blacklist incorrectly"
        );
    }

    function testAddToSuperwhitelistOnlyOwnerOrSuperwhitelisted() public {
        address addressToAdd = address(0xC);

        // Attempt to add an address to the superwhitelist by a non-owner, non-superwhitelisted account
        vm.prank(addressToAdd);
        vm.expectRevert(
            "Only the owner or superwhitelisted can call this function"
        );
        swlToken.addToSuperwhitelist(addressToAdd);

        // Verify that the address is not added to the superwhitelist
        assertFalse(
            swlToken.superwhitelist(addressToAdd),
            "Address added to the superwhitelist incorrectly"
        );

        // Attempt to add an address to the superwhitelist by a superwhitelisted account
        vm.prank(superwhitelistedAddr);
        swlToken.addToSuperwhitelist(addressToAdd);

        // Verify that the address is added to the superwhitelist
        assertTrue(
            swlToken.superwhitelist(addressToAdd),
            "Address not added to the superwhitelist"
        );
    }
}
