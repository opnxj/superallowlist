// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SuperwhitelistERC20} from "../src/SuperwhitelistERC20.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract SuperwhitelistToken is SuperwhitelistERC20 {
    constructor() SuperwhitelistERC20("Superwhitelist Token", "SWLT", 18) {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}

contract SuperwhitelistERC20Test is Test {
    SuperwhitelistToken public swl;

    address public alice = address(0x123); // To superwhitelist
    address public bob = address(0x456); // To blacklist
    address public charlie = address(0x789);

    function setUp() public {
        swl = new SuperwhitelistToken();
        swl.mint(alice, 1);
        swl.mint(bob, 1);
        swl.mint(charlie, 1);
    }

    function testSuperwhitelist() public {
        swl.addToSuperwhitelist(alice);
        // Cannot blacklist after superwhitelisting
        vm.expectRevert(
            SuperwhitelistERC20
                .Error_SuperwhitelistedCannotBeBlacklisted
                .selector
        );
        swl.addToBlacklist(alice);
    }

    function testBlacklist() public {
        swl.addToBlacklist(bob);

        // Bob cannot transfer
        vm.prank(bob);
        vm.expectRevert(
            SuperwhitelistERC20.Error_BlacklistedCannotTransfer.selector
        );
        swl.transfer(charlie, 1);

        // Cannot transfer to Bob
        vm.prank(alice);
        vm.expectRevert(
            SuperwhitelistERC20.Error_BlacklistedCannotTransfer.selector
        );
        swl.transfer(bob, 1);

        // Alice cannot transferFrom Bob after approval
        vm.prank(bob);
        swl.approve(alice, 1);
        vm.prank(alice);
        vm.expectRevert(
            SuperwhitelistERC20.Error_BlacklistedCannotTransfer.selector
        );
        swl.transferFrom(bob, alice, 1);
    }
}
