// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SuperallowlistERC20} from "../src/SuperallowlistERC20.sol";

// Test contract that inherits from SuperallowlistERC20
contract MockSuperallowlistERC20 is SuperallowlistERC20 {
    constructor() SuperallowlistERC20("Superallowlist", "SWL", address(0)) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract SuperallowlistERC20Test is Test {
    MockSuperallowlistERC20 public swlToken;
    address public denylistedAddr;
    address public superallowlistedAddr;

    function setUp() public {
        swlToken = new MockSuperallowlistERC20();

        denylistedAddr = address(0x1);
        swlToken.addToDenylist(denylistedAddr);

        superallowlistedAddr = address(0x2);
        swlToken.addToSuperallowlist(superallowlistedAddr);

        swlToken.mint(denylistedAddr, 100);
        swlToken.mint(superallowlistedAddr, 100);
    }

    function testContractDeployment() public {
        // Verify the deployed contract's name, symbol, and decimals
        assertEq(swlToken.name(), "Superallowlist", "Incorrect token name");
        assertEq(swlToken.symbol(), "SWL", "Incorrect token symbol");
        assertEq(swlToken.decimals(), 18, "Incorrect decimal places");
    }

    function testAddToDenylist() public {
        assertTrue(
            swlToken.denylist(denylistedAddr),
            "Address not added to the denylist"
        );

        // Verify that normal addresses are able to transfer tokens
        vm.prank(address(superallowlistedAddr));
        bool success = swlToken.transfer(address(this), 100);
        assertTrue(success, "Normal address was not able to transfer tokens");

        // Verify that the denylisted address is prevented from transferring tokens
        vm.prank(denylistedAddr);
        vm.expectRevert("Address is denylisted");
        success = swlToken.transfer(address(this), 100);
        assertFalse(success, "Denylisted address was able to transfer tokens");
    }

    function testRemoveFromDenylist() public {
        assertTrue(
            swlToken.denylist(denylistedAddr),
            "Address not added to the denylist"
        );

        swlToken.removeFromDenylist(denylistedAddr);
        assertFalse(
            swlToken.denylist(denylistedAddr),
            "Address not removed from the denylist"
        );

        // Verify that the address can transfer tokens after being removed from the denylist
        vm.prank(denylistedAddr);
        bool success = swlToken.transfer(address(this), 100);
        assertTrue(
            success,
            "Address was not able to transfer tokens after removal from the denylist"
        );
    }

    function testAddToSuperallowlist() public {
        // Verify that the address is added to the superallowlist
        assertTrue(
            swlToken.superallowlist(superallowlistedAddr),
            "Address not added to the superallowlist"
        );

        // Verify that the address becomes immune to being denylisted
        vm.expectRevert("Cannot add superallowlisted address to the denylist");
        swlToken.addToDenylist(superallowlistedAddr);
        assertFalse(
            swlToken.denylist(superallowlistedAddr),
            "Address on the superallowlist was denylisted"
        );
    }

    function testAddSuperallowlistFromDenylist() public {
        // Add the same address to the superallowlist
        swlToken.addToSuperallowlist(denylistedAddr);

        // Verify that the address is removed from the denylist
        assertFalse(
            swlToken.denylist(denylistedAddr),
            "Address not removed from the denylist"
        );
    }

    function testSetDenylisterOnlyOwner() public {
        address newDenylister = address(0xA);

        // Attempt to set the denylister address by a non-owner account
        vm.prank(newDenylister);
        vm.expectRevert("Ownable: caller is not the owner");
        swlToken.setDenylister(newDenylister);

        // Verify that the denylister address remains unchanged
        assertEq(
            swlToken.denylister(),
            swlToken.owner(),
            "Denylister address changed incorrectly"
        );

        // Set the denylister address by the owner account
        vm.prank(swlToken.owner());
        swlToken.setDenylister(newDenylister);

        // Verify that the denylister address is updated
        assertEq(
            swlToken.denylister(),
            newDenylister,
            "Denylister address not updated"
        );
    }

    function testAddToDenylistOnlyDenylister() public {
        address addressToAdd = address(0xB);

        // Attempt to add an address to the denylist by a non-denylister account
        vm.prank(addressToAdd);
        vm.expectRevert("Only the denylister can call this function");
        swlToken.addToDenylist(addressToAdd);

        // Verify that the address is not added to the denylist
        assertFalse(
            swlToken.denylist(addressToAdd),
            "Address added to the denylist incorrectly"
        );
    }

    function testAddToSuperallowlistOnlyOwnerOrSuperallowlisted() public {
        address addressToAdd = address(0xC);

        // Attempt to add an address to the superallowlist by a non-owner, non-superallowlisted account
        vm.prank(addressToAdd);
        vm.expectRevert(
            "Only the owner or superallowlisted can call this function"
        );
        swlToken.addToSuperallowlist(addressToAdd);

        // Verify that the address is not added to the superallowlist
        assertFalse(
            swlToken.superallowlist(addressToAdd),
            "Address added to the superallowlist incorrectly"
        );

        // Attempt to add an address to the superallowlist by a superallowlisted account
        vm.prank(superallowlistedAddr);
        swlToken.addToSuperallowlist(addressToAdd);

        // Verify that the address is added to the superallowlist
        assertTrue(
            swlToken.superallowlist(addressToAdd),
            "Address not added to the superallowlist"
        );
    }
}
