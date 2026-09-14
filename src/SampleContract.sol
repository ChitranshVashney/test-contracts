// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SampleContract
/// @notice Small ETH bank with several intentional vulnerabilities. Audit practice only.
contract SampleContract {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @dev VULN: balance is cleared after the external call (reentrancy).
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        balances[msg.sender] = 0;
    }

    /// @dev VULN: no access control — anyone can credit themselves.
    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }

    /// @dev VULN: `tx.origin` auth can be phished through a helper contract.
    function changeOwner(address newOwner) external {
        require(tx.origin == owner, "not owner");
        owner = newOwner;
    }

    /// @dev VULN: `block.prevrandao` / timestamp are predictable in the same transaction.
    function play(uint256 guess) external payable {
        require(msg.value == 0.1 ether, "wrong fee");
        balances[msg.sender] += msg.value;

        uint256 secret = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, address(this))));
        if (guess == secret) {
            uint256 pot = address(this).balance;
            balances[msg.sender] = 0;
            (bool ok,) = msg.sender.call{value: pot}("");
            require(ok, "payout failed");
        }
    }

    /// @dev VULN: `unchecked` subtraction wraps if `amount` exceeds the balance.
    function transfer(address to, uint256 amount) external {
        unchecked {
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
    }

    /// @dev VULN: no nonce, deadline, or chain id — a valid signature can be replayed.
    function claimWithSignature(address from, uint256 amount, bytes calldata signature) external {
        require(_recover(keccak256(abi.encodePacked(from, amount)), signature) == from, "bad sig");
        require(balances[from] >= amount, "funds");
        balances[from] -= amount;
        balances[msg.sender] += amount;
    }

    function _recover(bytes32 digest, bytes calldata signature) internal pure returns (address) {
        require(signature.length == 65, "sig length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }
        return ecrecover(digest, v, r, s);
    }
}
