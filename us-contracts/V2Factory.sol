pragma solidity =0.5.16;

import "./interfaces/IUniswapV2Factory.sol";
import "./UniswapV2Pair.sol";

contract V2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    event LogString(string key,string value);
    event LogInt(string key,int value);
    event LogUint256(string key,uint256 value);
    event LogUint(string key,uint value);
    event LogAddress(string key,address value);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair)
    {
        emit LogAddress("V2Factory.createPair.owner(sender)",msg.sender);
        emit LogAddress("V2Factory.createPair.tokenA",tokenA);
        emit LogAddress("V2Factory.createPair.tokenB",tokenB);

        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "UniswapV2: PAIR_EXISTS"
        ); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        emit LogAddress("V2Factory.setFeeTo.owner(sender)",msg.sender);
        emit LogAddress("V2Factory.setFeeTo._feeTo",_feeTo);        
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        emit LogAddress("V2Factory.setFeeToSetter.owner(sender)",msg.sender);
        emit LogAddress("V2Factory.setFeeToSetter._feeToSetter",_feeToSetter);          
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
