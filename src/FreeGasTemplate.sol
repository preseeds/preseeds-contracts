// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FreeGasTemplate {
    // The order of _balances, _minFee, _issuer must not be changed to pass validation of VictionZ application
    mapping(address => uint256) private _balances;
    uint256 private _minFee;
    address private _owner;

    constructor(address owner) {
        _owner = owner;
    }

    /**
     * @notice For Apply VictionZ
     */
    function issuer() public view returns (address) {
        return _owner;
    }

    /**
     * @notice For Apply VictionZ
     */
    function minFee() public view returns (uint256) {
        return _minFee;
    }

    /**
     * @notice For Apply VictionZ
     */
    function balanceOf(address user) public view returns (uint256) {
        return _balances[user];
    }
}