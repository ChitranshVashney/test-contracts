// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20MintBurn {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title InflationVault
/// @notice Share-based vault with no virtual offset / dead shares.
/// @dev VULN: first depositor can donate tokens to inflate `totalShares` rounding and steal later deposits.
contract InflationVault {
    IERC20MintBurn public immutable asset;
    uint256 public totalShares;
    mapping(address => uint256) public sharesOf;

    constructor(address asset_) {
        asset = IERC20MintBurn(asset_);
    }

    function deposit(uint256 assets) external returns (uint256 shares) {
        uint256 pool = asset.balanceOf(address(this));
        shares = totalShares == 0 ? assets : (assets * totalShares) / pool;
        require(shares > 0, "zero shares");
        asset.transferFrom(msg.sender, address(this), assets);
        totalShares += shares;
        sharesOf[msg.sender] += shares;
    }

    function withdraw(uint256 shares) external returns (uint256 assets) {
        require(sharesOf[msg.sender] >= shares, "shares");
        uint256 pool = asset.balanceOf(address(this));
        assets = (shares * pool) / totalShares;
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;
        asset.transfer(msg.sender, assets);
    }
}
