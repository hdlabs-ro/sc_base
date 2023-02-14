// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

contract RONT is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    event LogString(string key,string value);
    event LogInt(string key,int value);
    event LogUint256(string key,uint256 value);
    event LogAddress(string key,address value);
    
    constructor() {
        address owner = _msgSender();
        _name = "RONT Token";
        _symbol = "RONT";
        _totalSupply += 1000000000000000000000000; //1M
        _balances[owner] += 500000000000000000000; //500
    }

    //GETTERS
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    // SETTERS
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        emit LogAddress(string.concat(_symbol, ".transfer.owner(sender)"),owner);
        emit LogAddress(string.concat(_symbol, ".transfer.to"),to);
        emit LogUint256(string.concat(_symbol, ".transfer.amount"),amount);        
        _transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        emit LogAddress(string.concat(_symbol, ".approve.owner(sender)"),owner);
        emit LogAddress(string.concat(_symbol, ".approve.spender"),spender);
        emit LogUint256(string.concat(_symbol, ".approve.amount"),amount);          
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        emit LogAddress(string.concat(_symbol, ".transferFrom.spender(sender)"),spender);
        emit LogAddress(string.concat(_symbol, ".transferFrom.from"),from);
        emit LogAddress(string.concat(_symbol, ".transferFrom.to"),to);
        emit LogUint256(string.concat(_symbol, ".transferFrom.amount"),amount);           
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        emit LogAddress(string.concat(_symbol, ".increaseAllowance.owner(sender)"),owner);
        emit LogAddress(string.concat(_symbol, ".increaseAllowance.spender"),spender);
        emit LogUint256(string.concat(_symbol, ".increaseAllowance.addedValue"),addedValue);          
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        emit LogAddress(string.concat(_symbol, ".increaseAllowance.owner(sender)"),owner);
        emit LogAddress(string.concat(_symbol, ".increaseAllowance.spender"),spender);
        emit LogUint256(string.concat(_symbol, ".increaseAllowance.subtractedValue"),subtractedValue);   
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // PRVATE METHODS
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        emit LogAddress(string.concat(_symbol, "._transfer.from"),from);
        emit LogAddress(string.concat(_symbol, "._transfer.to"),to);
        emit LogUint256(string.concat(_symbol, "._transfer.amount"),amount);        
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        emit LogAddress(string.concat(_symbol, "._approve.owner"),owner);
        emit LogAddress(string.concat(_symbol, "._approve.spender"),spender);
        emit LogUint256(string.concat(_symbol, "._approve.amount"),amount);          
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        emit LogAddress(string.concat(_symbol, "._spendAllowance.owner"),owner);
        emit LogAddress(string.concat(_symbol, "._spendAllowance.spender"),spender);
        emit LogUint256(string.concat(_symbol, "._spendAllowance.amount"),amount);          
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}
