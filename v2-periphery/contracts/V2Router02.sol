pragma solidity =0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

import './interfaces/IUniswapV2Router02.sol';
import './libraries/UniswapV2Library.sol';
import './libraries/SafeMath.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';

contract V2Router02 is IUniswapV2Router02 {
    using SafeMath for uint256;

    address public immutable override factory;
    address public immutable override WETH;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    event LogString(string key,string value);
    event LogInt(string key,int value);
    event LogUint256(string key,uint256 value);
    event LogUint(string key,uint value);
    event LogUint112(string key,uint112 value);
    event LogAddress(string key,address value);
    event LogBool(string key,bool value);

    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {

        emit LogAddress("V2Router02._addLiquidity.owner(sender)",msg.sender);
        emit LogAddress("V2Router02._addLiquidity.tokenA",tokenA);
        emit LogAddress("V2Router02._addLiquidity.tokenB",tokenB);
        emit LogUint256("V2Router02._addLiquidity.amountADesired",amountADesired);
        emit LogUint256("V2Router02._addLiquidity.amountBDesired",amountBDesired);
        emit LogUint256("V2Router02._addLiquidity.amountAMin",amountAMin);
        emit LogUint256("V2Router02._addLiquidity.amountBMin",amountBMin);

        // create the pair if it doesn't exist yet
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }

        emit LogUint256("V2Router02._addLiquidity(end).amountA",amountA);
        emit LogUint256("V2Router02._addLiquidity(end).amountB",amountB);        
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        emit LogAddress("V2Router02.addLiquidity.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.addLiquidity.tokenA",tokenA);
        emit LogAddress("V2Router02.addLiquidity.tokenB",tokenB);
        emit LogUint256("V2Router02.addLiquidity.amountADesired",amountADesired);
        emit LogUint256("V2Router02.addLiquidity.amountBDesired",amountBDesired);
        emit LogUint256("V2Router02.addLiquidity.amountAMin",amountAMin);
        emit LogUint256("V2Router02.addLiquidity.amountBMin",amountBMin);
        emit LogAddress("V2Router02.addLiquidity.to",to);
        emit LogUint256("V2Router02.addLiquidity.deadline",deadline);

        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        _safeTransferFrom(tokenA, msg.sender, pair, amountA);
        _safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IUniswapV2Pair(pair).mint(to);

        emit LogUint256("V2Router02.addLiquidity(end).amountA",amountA);
        emit LogUint256("V2Router02.addLiquidity(end).amountB",amountB);
        emit LogUint256("V2Router02.addLiquidity(end).liquidity",liquidity);
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        emit LogAddress("V2Router02.addLiquidityETH.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.addLiquidityETH.token",token);
        emit LogUint256("V2Router02.addLiquidityETH.amountTokenDesired",amountTokenDesired);
        emit LogUint256("V2Router02.addLiquidityETH.amountTokenMin",amountTokenMin);
        emit LogUint256("V2Router02.addLiquidityETH.amountETHMin",amountETHMin);
        emit LogAddress("V2Router02.addLiquidityETH.to",to);
        emit LogUint256("V2Router02.addLiquidityETH.deadline",deadline);

        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        _safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IUniswapV2Pair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) _safeTransferETH(msg.sender, msg.value - amountETH);
        emit LogUint256("V2Router02.addLiquidityETH(end).amountToken",amountToken);
        emit LogUint256("V2Router02.addLiquidityETH(end).amountETH",amountETH);
        emit LogUint256("V2Router02.addLiquidityETH(end).liquidity",liquidity);        
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        
        emit LogAddress("V2Router02.removeLiquidity.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.removeLiquidity.tokenA",tokenA);
        emit LogAddress("V2Router02.removeLiquidity.tokenB",tokenB);
        emit LogUint256("V2Router02.removeLiquidity.liquidity",liquidity);
        emit LogUint256("V2Router02.removeLiquidity.amountAMin",amountAMin);
        emit LogUint256("V2Router02.removeLiquidity.amountBMin",amountBMin);
        emit LogAddress("V2Router02.removeLiquidity.to",to);
        emit LogUint256("V2Router02.removeLiquidity.deadline",deadline);

        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IUniswapV2Pair(pair).burn(to);
        (address token0, ) = UniswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');

        emit LogUint256("V2Router02.removeLiquidity(end).amountA",amountA);
        emit LogUint256("V2Router02.removeLiquidity(end).amountB",amountB);
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountToken, uint256 amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        emit LogAddress("V2Router02.removeLiquidityETH.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.removeLiquidityETH.token",token);
        emit LogUint256("V2Router02.removeLiquidityETH.liquidity",liquidity);
        emit LogUint256("V2Router02.removeLiquidityETH.amountTokenMin",amountTokenMin);
        emit LogUint256("V2Router02.removeLiquidityETH.amountETHMin",amountETHMin);
        emit LogAddress("V2Router02.removeLiquidityETH.to",to);
        emit LogUint256("V2Router02.removeLiquidityETH.deadline",deadline);

        _safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        _safeTransferETH(to, amountETH);

        emit LogUint256("V2Router02.removeLiquidityETH(end).amountToken",amountToken);
        emit LogUint256("V2Router02.removeLiquidityETH(end).amountETH",amountETH);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountA, uint256 amountB) {

        emit LogAddress("V2Router02.removeLiquidityWithPermit.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.removeLiquidityWithPermit.tokenA",tokenA);
        emit LogAddress("V2Router02.removeLiquidityWithPermit.tokenB",tokenB);
        emit LogUint256("V2Router02.removeLiquidityWithPermit.liquidity",liquidity);
        emit LogUint256("V2Router02.removeLiquidityWithPermit.amountAMin",amountAMin);
        emit LogUint256("V2Router02.removeLiquidityWithPermit.amountBMin",amountBMin);
        emit LogAddress("V2Router02.removeLiquidityWithPermit.to",to);
        emit LogUint256("V2Router02.removeLiquidityWithPermit.deadline",deadline);
        emit LogBool("V2Router02.removeLiquidityWithPermit.approveMax",approveMax);
        

        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);

        emit LogUint256("V2Router02.removeLiquidityWithPermit(end).amountA",amountA);
        emit LogUint256("V2Router02.removeLiquidityWithPermit(end).amountB",amountB);
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountToken, uint256 amountETH) {

        emit LogAddress("V2Router02.removeLiquidityETHWithPermit.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.removeLiquidityETHWithPermit.token",token);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermit.liquidity",liquidity);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermit.amountTokenMin",amountTokenMin);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermit.amountETHMin",amountETHMin);
        emit LogAddress("V2Router02.removeLiquidityETHWithPermit.to",to);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermit.deadline",deadline);
        emit LogBool("V2Router02.removeLiquidityETHWithPermit.approveMax",approveMax);

        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);

        emit LogUint256("V2Router02.removeLiquidityETHWithPermit(end).amountToken",amountToken);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermit(end).amountETH",amountETH);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountETH) {

        emit LogAddress("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens.token",token);
        emit LogUint256("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens.liquidity",liquidity);
        emit LogUint256("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens.amountTokenMin",amountTokenMin);
        emit LogUint256("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens.amountETHMin",amountETHMin);
        emit LogAddress("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens.to",to);
        emit LogUint256("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens.deadline",deadline);

        (, amountETH) = removeLiquidity(token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        _safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        _safeTransferETH(to, amountETH);

        emit LogUint256("V2Router02.removeLiquidityETHSupportingFeeOnTransferTokens(end).amountETH",amountETH);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountETH) {

        emit LogAddress("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.owner(sender)",msg.sender);
        emit LogAddress("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.token",token);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.liquidity",liquidity);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.amountTokenMin",amountTokenMin);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.amountETHMin",amountETHMin);
        emit LogAddress("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.to",to);
        emit LogUint256("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.deadline",deadline);
        emit LogBool("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens.approveMax",approveMax);

        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );

        emit LogUint256("V2Router02.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(end).amountETH",amountETH);
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        emit LogAddress("V2Router02._swap.owner(sender)",msg.sender);
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;

            emit LogAddress("V2Router02._swap.tokenInput",input);
            emit LogAddress("V2Router02._swap.tokenOutput",output);
            emit LogUint256("V2Router02._swap.amount0Out",amount0Out);
            emit LogUint256("V2Router02._swap.amount1Out",amount1Out);
            emit LogAddress("V2Router02._swap.to",to);

            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {

        emit LogAddress("V2Router02.swapExactTokensForTokens.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapExactTokensForTokens.amountIn",amountIn);
        emit LogUint256("V2Router02.swapExactTokensForTokens.amountOutMin",amountOutMin);
        emit LogAddress("V2Router02.swapExactTokensForTokens.to",to);
        emit LogUint256("V2Router02.swapExactTokensForTokens.deadline",deadline);
        emit LogString("V2Router02.swapExactTokensForTokens.path","Not logged");

        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        _safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {


        emit LogAddress("V2Router02.swapTokensForExactTokens.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapTokensForExactTokens.amountOut",amountOut);
        emit LogUint256("V2Router02.swapTokensForExactTokens.amountInMax",amountInMax);
        emit LogAddress("V2Router02.swapTokensForExactTokens.to",to);
        emit LogUint256("V2Router02.swapTokensForExactTokens.deadline",deadline);
        emit LogString("V2Router02.swapTokensForExactTokens.path","Not logged");

        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        _safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) returns (uint256[] memory amounts) {

        emit LogAddress("V2Router02.swapExactETHForTokens.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapExactETHForTokens.amountOutMin",amountOutMin);
        emit LogAddress("V2Router02.swapExactETHForTokens.to",to);
        emit LogUint256("V2Router02.swapExactETHForTokens.deadline",deadline);
        emit LogString("V2Router02.swapExactETHForTokens.path","Not logged");

        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {

        emit LogAddress("V2Router02.swapTokensForExactETH.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapTokensForExactETH.amountOut",amountOut);
        emit LogUint256("V2Router02.swapTokensForExactETH.amountInMax",amountInMax);
        emit LogAddress("V2Router02.swapTokensForExactETH.to",to);
        emit LogUint256("V2Router02.swapTokensForExactETH.deadline",deadline);
        emit LogString("V2Router02.swapTokensForExactETH.path","Not logged");

        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        _safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        _safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {

        emit LogAddress("V2Router02.swapTokensForExactETH.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapTokensForExactETH.amountIn",amountIn);
        emit LogUint256("V2Router02.swapTokensForExactETH.amountOutMin",amountOutMin);
        emit LogAddress("V2Router02.swapTokensForExactETH.to",to);
        emit LogUint256("V2Router02.swapTokensForExactETH.deadline",deadline);
        emit LogString("V2Router02.swapTokensForExactETH.path","Not logged");

        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        _safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        _safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) returns (uint256[] memory amounts) {

        emit LogAddress("V2Router02.swapETHForExactTokens.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapETHForExactTokens.amountOut",amountOut);
        emit LogAddress("V2Router02.swapETHForExactTokens.to",to);
        emit LogUint256("V2Router02.swapETHForExactTokens.deadline",deadline);
        emit LogString("V2Router02.swapETHForExactTokens.path","Not logged");

        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) _safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {

        emit LogAddress("V2Router02._swapSupportingFeeOnTransferTokens._to",_to);
        emit LogString("V2Router02._swapSupportingFeeOnTransferTokens.path","Not logged");

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output));
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {

        emit LogAddress("V2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens.amountIn",amountIn);
        emit LogUint256("V2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens.amountOutMin",amountOutMin);
        emit LogAddress("V2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens.to",to);
        emit LogUint256("V2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens.deadline",deadline);
        emit LogString("V2Router02.swapExactTokensForTokensSupportingFeeOnTransferTokens.path","Not logged");

        _safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {

        emit LogAddress("V2Router02.swapExactETHForTokensSupportingFeeOnTransferTokens.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapExactETHForTokensSupportingFeeOnTransferTokens.amountOutMin",amountOutMin);
        emit LogAddress("V2Router02.swapExactETHForTokensSupportingFeeOnTransferTokens.to",to);
        emit LogUint256("V2Router02.swapExactETHForTokensSupportingFeeOnTransferTokens.deadline",deadline);
        emit LogString("V2Router02.swapExactETHForTokensSupportingFeeOnTransferTokens.path","Not logged");

        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        uint256 amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {

        emit LogAddress("V2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens.owner(sender)",msg.sender);
        emit LogUint256("V2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens.amountIn",amountIn);
        emit LogUint256("V2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens.amountOutMin",amountOutMin);
        emit LogAddress("V2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens.to",to);
        emit LogUint256("V2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens.deadline",deadline);
        emit LogString("V2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens.path","Not logged");

        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        _safeTransferFrom(
            path[0],
            msg.sender,
            UniswapV2Library.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        _safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {

        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountOut) {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountIn) {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        emit LogAddress("V2Router02._safeTransfer.owner(sender)",msg.sender);
        emit LogAddress("V2Router02._safeTransfer.token",token);
        emit LogAddress("V2Router02._safeTransfer.to",to);
        emit LogUint256("V2Router02._safeTransfer.value",value);

        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        bool success = IERC20(token).transfer(to, value);
        require(success, 'TransferHelper::safeTransfer: transfer failed');
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        bool success = IERC20(token).transferFrom(from, to, value);
        require(success, 'TransferHelper::transferFrom: transferFrom failed ');
    }

    function _safeTransferETH(address  to, uint256 value) internal {
        //As they say but it was not working - must be payable
        (bool success, ) = to.call{value: value}(new bytes(0));
        //as we try
        //bool success = to.transfer(value);
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }    
}
