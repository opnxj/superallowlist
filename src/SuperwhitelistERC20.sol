// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract SuperwhitelistERC20 is ERC20, Ownable {
    mapping(address => bool) public superwhitelist;
    mapping(address => bool) public blacklist;

    constructor() ERC20("SuperwhitelistERC20", "SWL", 18) {
        // Mint 1000 tokens to the deployer, for testing
        _mint(msg.sender, 1000 ether);
    }

    error Error_SuperwhitelistedCannotBeBlacklisted();
    error Error_BlacklistedCannotTransfer();

    modifier notSuperwhitelisted(address _addr) {
        if (superwhitelist[_addr]) {
            revert Error_SuperwhitelistedCannotBeBlacklisted();
        }
        _;
    }

    modifier notBlacklisted(address _addr) {
        if (blacklist[_addr]) {
            revert Error_BlacklistedCannotTransfer();
        }
        _;
    }

    function addToSuperwhitelist(address _addr) external onlyOwner {
        superwhitelist[_addr] = true;
    }

    function addToBlacklist(
        address _addr
    ) external onlyOwner notSuperwhitelisted(_addr) {
        blacklist[_addr] = true;
    }

    function removeFromBlacklist(address _addr) external onlyOwner {
        blacklist[_addr] = false;
    }

    function transfer(
        address _to,
        uint256 _amount
    )
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        super.transfer(_to, _amount);
    }
}
