// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/Faucet.sol";

contract FaucetScript is Script {
    function run() external returns (Faucet faucet) {
        vm.startBroadcast();

        faucet = new Faucet();

        vm.stopBroadcast();
    }
}
