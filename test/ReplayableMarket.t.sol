// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ReplayableMarket} from "../src/ReplayableMarket.sol";

contract ReplayableMarketTest is Test {
    ReplayableMarket internal market;
    uint256 internal sellerKey = 0xA11CE;
    address internal seller;
    address internal buyer = makeAddr("buyer");

    function setUp() public {
        seller = vm.addr(sellerKey);
        market = new ReplayableMarket();

        vm.deal(buyer, 10 ether);
        vm.prank(buyer);
        market.deposit{value: 4 ether}();
    }

    function test_SignatureCanBeReplayed() public {
        uint256 price = 1 ether;
        bytes32 digest = keccak256(abi.encodePacked(seller, price));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sellerKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(buyer);
        market.buyWithSignature(seller, price, signature);
        market.buyWithSignature(seller, price, signature);
        vm.stopPrank();

        assertEq(market.deposits(seller), 2 ether);
        assertEq(market.deposits(buyer), 2 ether);
    }
}
