// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ILog.sol";

contract HDFactory is ILog {
    address public feeTo;
    address public feeToSetter;
    address token0 = 0xd9145CCE52D386f254917e481eB44e9943F39138; //RONT contract
    address token1 = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8; //USDT contract

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
        address pair = 0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B;
        allPairs.push(pair);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair)
    {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "UniswapV2: PAIR_EXISTS"
        ); // single check is sufficient
        emit Log(
            "factory createPair called with no results, pairs are predefined"
        );
        return getPair[token1][token0];
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}