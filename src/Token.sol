// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "openzeppelin/token/ERC20/ERC20.sol";

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IBaryonPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IBaryonFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}


contract Token is ERC20 {
    uint256 public immutable rate = 10**6; // 1 VIC = 10**6 TOKEN
    address public immutable factory;
    IWETH public immutable weth = IWETH(address(0x1));
    IBaryonFactory public immutable baryonFactory = IBaryonFactory(address(0x2));
    bytes32 public immutable SENTINEL_MESSAGE = keccak256("vic");

    bool public isPoolCreated;
    uint256 public unlockDate;
    uint256 public targetLiquidity;
    string public imageUrl;
    string public description;
    address public creatorAddress;

    struct Message {
        address sender;
        string message;
        uint256 timestamp;
    }

    uint256 public messageCount;
    mapping(bytes32 => Message) public messages;
    mapping(bytes32 => bytes32) public messagesHashes;

    event PoolCreated();
    event MessageCreated(address indexed sender, string message, uint256 timestamp);

    constructor(string memory name, string memory symbol, string memory image, string memory descriptionInput, uint256 unlockTime, uint256 targetLiquidityInput, address creator) ERC20(name, symbol) {
        creatorAddress = creator;
        imageUrl = image;
        description = descriptionInput;
        targetLiquidity = targetLiquidityInput;
        unlockDate = block.timestamp + unlockTime;

        factory = msg.sender;
        messagesHashes[SENTINEL_MESSAGE] = SENTINEL_MESSAGE;
    }

    function mint() public payable {
        require(!eligibleForPool(), "Token: locked");
        require(!isPoolCreated, "Token: pool already created");
        require(msg.value > 0 && msg.value <= targetLiquidity - address(this).balance, "Token: invalid amount");

        _mint(msg.sender, msg.value * rate);
    }

    function createPool() external {
        require(!isPoolCreated, "Token: pool already created");
        require(eligibleForPool(), "Token: locked");

        address pair = baryonFactory.getPair(address(this), address(weth));
        if (pair == address(0)) {
            pair = baryonFactory.createPair(address(this), address(weth));
        }
        uint256 vicBalance = address(this).balance;
        uint256 tokenSupply = totalSupply();

        weth.deposit{value: vicBalance}();
        assert(weth.transfer(pair, vicBalance));
        _mint(pair, tokenSupply);
        IBaryonPair(pair).mint(address(0));

        isPoolCreated = true;

        emit PoolCreated();
    }

    function createMessage(string memory message) external {
        bytes32 messageHash = keccak256(abi.encodePacked(message, msg.sender, block.timestamp));
        messages[messageHash] = Message(msg.sender, message, block.timestamp);
        messagesHashes[messageHash] = messagesHashes[SENTINEL_MESSAGE];
        messagesHashes[SENTINEL_MESSAGE] = messageHash;
        messageCount++;

        emit MessageCreated(msg.sender, message, block.timestamp);
    }

    function eligibleForPool() public view returns (bool) {
        return block.timestamp > unlockDate || address(this).balance >= targetLiquidity;
    }

    function getMessages(uint256 limit) external view returns (Message[] memory result) {
        if (limit > messageCount) {
            limit = messageCount;
        }
        result = new Message[](limit);
        bytes32 current = messagesHashes[SENTINEL_MESSAGE];
        for (uint256 i = 0; i < limit && current != SENTINEL_MESSAGE; i++) {
            result[i] = messages[current];
            current = messagesHashes[current];
        }
    }

    function getTokenInfo() external view returns (string memory, string memory, string memory, string memory, uint256, uint256, uint256, uint256, address, bool) {
        return (name(), symbol(), imageUrl, description, totalSupply(), address(this).balance, unlockDate, targetLiquidity, creatorAddress, isPoolCreated);
    }

    fallback() external {
        mint();
    }

    receive() external payable {
        mint();
    }
}
