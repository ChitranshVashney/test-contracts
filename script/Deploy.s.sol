// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {InsecureVault} from "../src/InsecureVault.sol";
import {UnprotectedToken} from "../src/UnprotectedToken.sol";
import {GuessTheSecret} from "../src/GuessTheSecret.sol";
import {ReplayableMarket} from "../src/ReplayableMarket.sol";
import {UnsafeProxy} from "../src/UnsafeProxy.sol";
import {UncheckedWallet} from "../src/UncheckedWallet.sol";
import {SpotPricedPool} from "../src/SpotPricedPool.sol";
import {SilentTokenBank} from "../src/SilentTokenBank.sol";
import {InflationVault} from "../src/InflationVault.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        InsecureVault vault = new InsecureVault();
        UnprotectedToken token = new UnprotectedToken();
        GuessTheSecret game = new GuessTheSecret();
        ReplayableMarket market = new ReplayableMarket();
        UnsafeProxy proxy = new UnsafeProxy();
        UncheckedWallet wallet = new UncheckedWallet();

        MockERC20 asset = new MockERC20("Sample Asset", "SAMP");
        asset.mint(msg.sender, 1_000_000 ether);

        SpotPricedPool pool = new SpotPricedPool{value: 1 ether}(address(asset));
        asset.mint(address(pool), 1_000 ether);

        SilentTokenBank bank = new SilentTokenBank(address(asset));
        InflationVault inflation = new InflationVault(address(asset));

        vm.stopBroadcast();

        console.log("InsecureVault", address(vault));
        console.log("UnprotectedToken", address(token));
        console.log("GuessTheSecret", address(game));
        console.log("ReplayableMarket", address(market));
        console.log("UnsafeProxy", address(proxy));
        console.log("UncheckedWallet", address(wallet));
        console.log("MockERC20", address(asset));
        console.log("SpotPricedPool", address(pool));
        console.log("SilentTokenBank", address(bank));
        console.log("InflationVault", address(inflation));
    }
}
