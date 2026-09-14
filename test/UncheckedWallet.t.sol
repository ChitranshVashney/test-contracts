// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UncheckedWallet} from "../src/UncheckedWallet.sol";

contract UncheckedWalletTest is Test {
    UncheckedWallet internal wallet;
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        wallet = new UncheckedWallet();
    }

    function test_UncheckedTransferWrapsBalance() public {
        address sink = makeAddr("sink");

        vm.prank(attacker);
        wallet.transfer(sink, 1);

        assertEq(wallet.balances(attacker), type(uint256).max);
        assertEq(wallet.balances(sink), 1);
    }
}
