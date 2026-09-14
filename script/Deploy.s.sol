// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SampleContract} from "../src/SampleContract.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        SampleContract bank = new SampleContract();
        vm.stopBroadcast();

        console.log("SampleContract", address(bank));
    }
}
