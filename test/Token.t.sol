// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    function setUp() public {
        token = new Token("Vicoin", "VIC", "https://vicoin.io", "", 86400, 10 ether, address(this));
    }

    function testBuy() public {
        (bool success, ) = payable(address(token)).call{value: 11 ether}("");
        require(success, "TokenTest: buy failed");
        uint256 balance = token.balanceOf(address(this));
    }

    receive() external payable {}
}
