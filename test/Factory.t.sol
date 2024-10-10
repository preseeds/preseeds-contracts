// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";

contract FactoryTest is Test {
    Factory public factory;
    address owner = address(0x11);
    address user = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        factory = new Factory(1 ether);
        vm.stopPrank();
    }

    function testCreateToken() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        factory.createToken{value: 1 ether}("Test Token", "TST", "https://test.io", "", 86400, 10 ether, bytes32(0));
        vm.stopPrank();
    }

    function testWithdrawFund() public {
        vm.startPrank(owner);
        vm.deal(address(factory), 1 ether);
        factory.withdrawFund();

        require(address(owner).balance == 1 ether, "FactoryTest: withdraw failed");
        vm.stopPrank();
    }

    function testUpdateCreationFee() public {
        vm.startPrank(owner);
        factory.setCreationFee(2 ether);
        
        require(factory.creationFee() == 2 ether, "FactoryTest: update failed");
        vm.stopPrank();
    }
}
