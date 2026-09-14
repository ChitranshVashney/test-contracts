// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title SpotPricedPool
/// @notice Lends tokens against ETH using the pool's own spot balances as the price.
/// @dev VULN: anyone can donate tokens to inflate `tokensPerEth` and over-borrow.
contract SpotPricedPool {
    IERC20 public immutable token;
    mapping(address => uint256) public collateralEth;
    mapping(address => uint256) public debtToken;

    constructor(address token_) payable {
        require(msg.value > 0, "seed eth");
        token = IERC20(token_);
    }

    function tokensPerEth() public view returns (uint256) {
        return (token.balanceOf(address(this)) * 1e18) / address(this).balance;
    }

    function depositCollateral() external payable {
        collateralEth[msg.sender] += msg.value;
    }

    function borrow(uint256 tokenAmount) external {
        uint256 maxBorrow = (collateralEth[msg.sender] * tokensPerEth()) / 1e18;
        require(debtToken[msg.sender] + tokenAmount <= maxBorrow, "undercollateralized");
        debtToken[msg.sender] += tokenAmount;
        require(token.transfer(msg.sender, tokenAmount), "transfer");
    }
}
