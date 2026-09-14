// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ReplayableMarket
/// @notice Lets a seller authorize a listing with an off-chain signature.
/// @dev VULN: no nonce, deadline, or chain id — a valid signature can be replayed forever.
contract ReplayableMarket {
    mapping(address => uint256) public deposits;

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
    }

    function buyWithSignature(address seller, uint256 price, bytes calldata signature) external {
        require(deposits[msg.sender] >= price, "buyer funds");
        require(_recover(keccak256(abi.encodePacked(seller, price)), signature) == seller, "bad sig");

        deposits[msg.sender] -= price;
        deposits[seller] += price;
    }

    function withdraw() external {
        uint256 amount = deposits[msg.sender];
        deposits[msg.sender] = 0;
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "withdraw failed");
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
