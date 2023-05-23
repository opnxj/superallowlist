// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SuperwhitelistERC20} from "../src/SuperwhitelistERC20.sol";

contract SuperwhitelistERC20Test is Test {
    SuperwhitelistERC20 public swl;

    function setUp() public {
        swl = new SuperwhitelistERC20();
    }

    function testBlacklist() public {
        address bad = address(0x1);
        swl.addToBlacklist(bad);
        vm.expectRevert(
            SuperwhitelistERC20.Error_BlacklistedCannotTransfer.selector
        );
        swl.transfer(bad, 1); // Try transfer, show that it fails

        address good = address(0x2);
        swl.transfer(good, 1); // Show that this works
    }

    function testSuperwhitelist() public {
        address good = address(0x2);
        swl.addToSuperwhitelist(good);
        vm.expectRevert(
            SuperwhitelistERC20
                .Error_SuperwhitelistedCannotBeBlacklisted
                .selector
        );
        swl.addToBlacklist(good); // Try blacklist, show that it fails
    }
}
