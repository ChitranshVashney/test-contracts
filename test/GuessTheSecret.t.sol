// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GuessTheSecret} from "../src/GuessTheSecret.sol";

contract GuessTheSecretTest is Test {
    GuessTheSecret internal game;

    function setUp() public {
        game = new GuessTheSecret();
        vm.deal(address(game), 5 ether);
    }

    function test_OnChainRandomnessIsPredictable() public {
        uint256 secret = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, address(game))));

        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        game.play{value: 0.1 ether}(secret);

        assertEq(address(game).balance, 0);
        assertEq(attacker.balance, 6 ether);
    }
}
