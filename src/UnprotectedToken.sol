// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title UnprotectedToken
/// @notice Minimal mintable token with broken authorization.
/// @dev VULN 1: `mint` has no access control — anyone can mint.
/// @dev VULN 2: `changeOwner` trusts `tx.origin`, so a phishing contract can hijack ownership.
contract UnprotectedToken {
    string public constant name = "Sample Token";
    string public constant symbol = "SMPL";
    uint8 public constant decimals = 18;

    address public owner;
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    constructor() {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function changeOwner(address newOwner) external {
        require(tx.origin == owner, "not owner");
        owner = newOwner;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}
