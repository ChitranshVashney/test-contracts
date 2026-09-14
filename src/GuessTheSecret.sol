// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GuessTheSecret
/// @notice Pay-to-play guessing game that uses on-chain entropy.
/// @dev VULN: `block.prevrandao` and `block.timestamp` are predictable to a miner / attacker contract.
contract GuessTheSecret {
    uint256 public constant ENTRY_FEE = 0.1 ether;

    function play(uint256 guess) external payable {
        require(msg.value == ENTRY_FEE, "wrong fee");

        uint256 secret = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, address(this))));

        if (guess == secret) {
            (bool ok,) = msg.sender.call{value: address(this).balance}("");
            require(ok, "payout failed");
        }
    }
}
