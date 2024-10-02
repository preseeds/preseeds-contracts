// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "openzeppelin/access/Ownable.sol";

import "./Token.sol";

contract Factory is Ownable {
    uint256 public tokenCount;
    address public constant SENTINEL_ADDRESS = address(0x1);

    mapping(address => address) public tokens;

    uint256 public creationFee;

    event UpdateCreationFee(uint256 fee);
    event CreateToken(address indexed token, string name, string symbol, string image, uint256 unlockTime, uint256 targetLiquidity, address indexed creator);

    struct TokenInfo {
        address token;
        string name;
        string symbol;
        string image;
        uint256 unlockTime;
        uint256 targetLiquidity;
        uint256 raisedAmount;
    }

    constructor() Ownable() {
        tokens[SENTINEL_ADDRESS] = SENTINEL_ADDRESS;
    }

    function createToken(string memory name, string memory symbol, string memory image, uint256 unlockTime, uint256 targetLiquidity) external payable returns (address token) {
        require(msg.value >= creationFee, "Factory: insufficient fee");
        token = address(new Token(name, symbol, image,  unlockTime, targetLiquidity, msg.sender));
        tokens[token] = tokens[SENTINEL_ADDRESS];
        tokens[SENTINEL_ADDRESS] = token;
        tokenCount++;
        emit CreateToken(token, name, symbol, image, unlockTime, targetLiquidity, msg.sender);
        return token;
    }

    function withdrawFund() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setCreationFee(uint256 fee) external onlyOwner {
        creationFee = fee;

        emit UpdateCreationFee(fee);
    }
    
    function getTokenInfos(uint256 limit) external view returns (TokenInfo[] memory result) {
        result = new TokenInfo[](limit);
        address current = tokens[SENTINEL_ADDRESS];
        for (uint256 i = 0; i < limit && current != SENTINEL_ADDRESS; i++) {
            Token token = Token(payable(current));
            result[i] = TokenInfo(current, token.name(), token.symbol(), token.imageUrl(), token.unlockDate(), token.targetLiquidity(), address(token).balance);
            current = tokens[current];
        }
    }

    fallback() external {}
    receive() external payable {}
}
