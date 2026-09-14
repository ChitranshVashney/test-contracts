// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SilentTokenBank} from "../src/SilentTokenBank.sol";
import {FalseReturningToken} from "../src/mocks/MockERC20.sol";

contract SilentTokenBankTest is Test {
    FalseReturningToken internal token;
    SilentTokenBank internal bank;
    address internal user = makeAddr("user");

    function setUp() public {
        token = new FalseReturningToken();
        bank = new SilentTokenBank(address(token));
        token.mint(user, 10 ether);
    }

    function test_FailedTransferStillCreditsShares() public {
        vm.startPrank(user);
        // No approve — transferFrom returns false, but the bank ignores it.
        bank.deposit(5 ether);
        vm.stopPrank();

        assertEq(bank.shares(user), 5 ether);
        assertEq(token.balanceOf(address(bank)), 0);
    }
}
