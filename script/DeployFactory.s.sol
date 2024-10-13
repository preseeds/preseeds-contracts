// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Factory.sol";

contract DeployFactoryScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Factory factory = new Factory(0);
        console.log("Factory deployed at: ", address(factory));

        vm.stopBroadcast();
    }
}
