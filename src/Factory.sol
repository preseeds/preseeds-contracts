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
    event WithdrawFund(address indexed owner, uint256 amount);

    struct TokenInfo {
        address token;
        bool isPoolCreated;
        string name;
        string symbol;
        string image;
        uint256 unlockTime;
        uint256 targetLiquidity;
        uint256 raisedAmount;
    }

    constructor(uint256 creationFeeInput) Ownable() {
        tokens[SENTINEL_ADDRESS] = SENTINEL_ADDRESS;
        creationFee = creationFeeInput;
    }

    function createToken(string memory name, string memory symbol, string memory image, string memory description, uint256 unlockTime, uint256 targetLiquidity, bytes32 salt) external payable returns (address token) {
        require(msg.value >= creationFee, "Factory: insufficient fee");
        token = address(new Token{salt: salt}(name, symbol, image, description, unlockTime, targetLiquidity, msg.sender));
        tokens[token] = tokens[SENTINEL_ADDRESS];
        tokens[SENTINEL_ADDRESS] = token;
        tokenCount++;
        emit CreateToken(token, name, symbol, image, unlockTime, targetLiquidity, msg.sender);
        return token;
    }

    function withdrawFund() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Factory: withdraw failed");

        emit WithdrawFund(msg.sender, address(this).balance);
    }

    function setCreationFee(uint256 fee) external onlyOwner {
        creationFee = fee;

        emit UpdateCreationFee(fee);
    }
    
    function getTokenInfos(uint256 limit) external view returns (TokenInfo[] memory result) {
        if (limit > tokenCount) {
            limit = tokenCount;
        }
        result = new TokenInfo[](limit);
        address current = tokens[SENTINEL_ADDRESS];
        for (uint256 i = 0; i < limit && current != SENTINEL_ADDRESS; i++) {
            Token token = Token(payable(current));
            result[i] = TokenInfo(current, token.isPoolCreated(), token.name(), token.symbol(), token.imageUrl(), token.unlockDate(), token.targetLiquidity(), address(token).balance);
            current = tokens[current];
        }
    }

    fallback() external {}
    receive() external payable {}
}
