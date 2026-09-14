// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Like {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title SilentTokenBank
/// @notice Token vault that ignores ERC-20 return values.
/// @dev VULN: some tokens return `false` instead of reverting; the bank still credits / debits.
contract SilentTokenBank {
    IERC20Like public immutable token;
    mapping(address => uint256) public shares;

    constructor(address token_) {
        token = IERC20Like(token_);
    }

    function deposit(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        shares[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(shares[msg.sender] >= amount, "shares");
        shares[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }
}
