// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {Token, IBaryonPair} from "../src/Token.sol";

contract TokenTest is Test {
    Factory public factory;
    Token public token;
    address owner = address(0x11);
    address user = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        factory = new Factory(0);
        token = Token(payable(factory.createToken("Test Token", "TST", "https://test.io", "", 86400, 10 ether, address(user), bytes32(0))));
        vm.stopPrank();
    }

    function testBuy() public {
        (bool success, ) = payable(address(token)).call{value: 9 ether}("");
        require(success, "TokenTest: buy failed");
        uint256 balance = token.balanceOf(address(this));
        require(balance == 9 ether * 10**6, "TokenTest: balance failed");
    }

    function testShouldDeployThePoolAndDistributeFee() public {
        uint256 ownerBalanceBefore = address(owner).balance;
        uint256 userBalanceBefore = address(user).balance;
        (bool success, ) = payable(address(token)).call{value: 10 ether}("");
        require(success, "TokenTest: buy failed");

        uint256 ownerBalanceAfter = address(owner).balance;
        uint256 userBalanceAfter = address(user).balance;

        uint256 fee = (10 ether) * 20 / 1000;

        require(ownerBalanceAfter == ownerBalanceBefore + fee, "TokenTest: owner balance failed");
        require(userBalanceAfter == userBalanceBefore + fee, "TokenTest: user balance failed");

        address pair = token.baryonFactory().getPair(address(token), address(token.weth()));
        require(pair != address(0), "TokenTest: pair failed");
    }

    function testShouldMintAllLqToZeroAddress() public {
        (bool success, ) = payable(address(token)).call{value: 10 ether}("");
        require(success, "TokenTest: buy failed");
        IBaryonPair pair = IBaryonPair(token.baryonFactory().getPair(address(token), address(token.weth())));

        require(pair.balanceOf(address(0)) == pair.totalSupply(), "TokenTest: mint failed");
    }

    receive() external payable {}
}
