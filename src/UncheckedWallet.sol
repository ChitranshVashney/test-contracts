// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title UncheckedWallet
/// @notice Internal-balance wallet that disables 0.8 overflow checks on transfer.
/// @dev VULN: `unchecked` lets a user send more than they hold; their balance wraps to a huge number.
contract UncheckedWallet {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address to, uint256 amount) external {
        unchecked {
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
    }
}
