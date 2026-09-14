// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title UnsafeProxy
/// @notice Thin "wallet" that forwards calls with `delegatecall`.
/// @dev VULN: anyone can `delegatecall` an arbitrary target and overwrite storage (including owner).
contract UnsafeProxy {
    address public owner;
    uint256 public value;

    constructor() {
        owner = msg.sender;
    }

    function execute(address target, bytes calldata data) external {
        (bool ok,) = target.delegatecall(data);
        require(ok, "delegatecall failed");
    }
}
