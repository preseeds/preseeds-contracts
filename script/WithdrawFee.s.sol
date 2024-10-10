// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Factory.sol";

contract DeployFactoryScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Factory factory = Factory(payable(0x11103e983745dB6D1802DC43766ad994Df3DB6ec));
        factory.withdrawFund();

        vm.stopBroadcast();
    }
}
