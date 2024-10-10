// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Token, IBaryonPair} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    function setUp() public {
        token = new Token("Vicoin", "VIC", "https://vicoin.io", "", 86400, 10 ether, address(this));
    }

    function testBuy() public {
        (bool success, ) = payable(address(token)).call{value: 9 ether}("");
        require(success, "TokenTest: buy failed");
        uint256 balance = token.balanceOf(address(this));
        require(balance == 9 ether * 10**6, "TokenTest: balance failed");
    }

    function testShouldDeployThePool() public {
        (bool success, ) = payable(address(token)).call{value: 10 ether}("");
        require(success, "TokenTest: buy failed");
        address pair = token.baryonFactory().getPair(address(token), address(token.weth()));
        require(pair != address(0), "TokenTest: pair failed");
    }

    function testShouldMintAllLqToZeroAddress() public {
        (bool success, ) = payable(address(token)).call{value: 10 ether}("");
        require(success, "TokenTest: buy failed");
        IBaryonPair pair = IBaryonPair(token.baryonFactory().getPair(address(token), address(token.weth())));
        console2.log(pair.balanceOf(address(0)));

        require(pair.balanceOf(address(0)) == pair.totalSupply(), "TokenTest: mint failed");
    }

    receive() external payable {}
}
