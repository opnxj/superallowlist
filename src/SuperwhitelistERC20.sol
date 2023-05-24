// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title SuperwhitelistERC20
 * @author opnxj
 * @dev This contract extends Solmate's ERC20 ipmlementation and adds blacklist/superwhitelist functionality.
 *      Users can be added to the superwhitelist by the contract owner, which gives immunity from being blacklisted.
 *      The contract owner can add and remove addresses from the blacklist.
 *      Transfers involving a blacklisted address will be reverted.
 */
abstract contract SuperwhitelistERC20 is ERC20, Ownable {
    mapping(address => bool) public superwhitelist;
    mapping(address => bool) public blacklist;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    event AddedToSuperwhitelist(address indexed _addr);
    event AddedToBlacklist(address indexed _addr);
    event RemovedFromBlacklist(address indexed _addr);

    error Error_SuperwhitelistedCannotBeBlacklisted();
    error Error_BlacklistedCannotTransfer();

    function addToSuperwhitelist(address _addr) public virtual onlyOwner {
        superwhitelist[_addr] = true;
        emit AddedToSuperwhitelist(_addr);
    }

    function addToBlacklist(address _addr) public virtual onlyOwner {
        if (superwhitelist[_addr]) {
            revert Error_SuperwhitelistedCannotBeBlacklisted();
        }
        blacklist[_addr] = true;
        emit AddedToBlacklist(_addr);
    }

    function removeFromBlacklist(address _addr) public virtual onlyOwner {
        blacklist[_addr] = false;
        emit RemovedFromBlacklist(_addr);
    }

    function transfer(
        address _to,
        uint256 _amount
    ) public virtual override returns (bool) {
        if (blacklist[msg.sender] || blacklist[_to]) {
            revert Error_BlacklistedCannotTransfer();
        }
        return super.transfer(_to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public virtual override returns (bool) {
        if (blacklist[_from] || blacklist[_to]) {
            revert Error_BlacklistedCannotTransfer();
        }
        return super.transferFrom(_from, _to, _amount);
    }
}
