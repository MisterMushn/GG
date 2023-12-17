/**
 *Submitted for verification at BscScan.com on 2021-11-18
*/

pragma solidity >=0.5.16;

// SPDX-License-Identifier: MIT


interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }
  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }
  
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
  
  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract UpCooming is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  
  uint256 private basePercent;
  uint256 private burnRate; 
  uint256 private mrKrabsRate; 
  uint256 private openingDateUnix;
  
  address private contractAddress;
  address private gameAddress;
  
  function setContractAdress(address _contractAddress) public onlyOwner returns (bool) {
      _setContractAddress(_contractAddress);
      return true;
  }
  function _setContractAddress(address _contractAddress) internal {
      contractAddress = _contractAddress;
  }
  function getContractAddress() public view returns (address) {
      return contractAddress;
  }

  enum State { LOCKED, OPEN }

  State private state;

  function setStateOPEN() public {
      if (block.timestamp > openingDateUnix){
          state = State.OPEN;
      }
  } 
  function setStateCLOSED() public onlyOwner {
      if (block.timestamp < openingDateUnix){
          state = State.LOCKED;
      }
  }
  function getState() public view onlyOwner returns(uint) {
      return uint(state);
  }


  function setGameAddress(address _gameAddress) public onlyOwner returns (bool){
    _setGameAddress(_gameAddress);
    return true;
  }

  function _setGameAddress(address _gameAddress) internal {
    gameAddress = _gameAddress;
  }

  function getGameAddress() public view returns (address) {
      return gameAddress;
  }

  address private UNI_FLOT;

  

  modifier ensure(address _from, address _to) {
      if(state == State.LOCKED){
          require(_from == owner() || _to == owner() || _from == contractAddress || /*tx.origin == owner() || */msg.sender == owner() || _from == gameAddress /*|| tx.origin == gameAddress */|| _to == gameAddress ||  msg.sender == gameAddress,"State is locked"); 
          _;
      }else{
          _;
      }
  }
  
  function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66'
            ))));
    }

  function percentToValue(uint256 value, uint256 percent) internal view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(percent);
    return onePercent;
  }
  
  function setBurnRate(uint256 amount) public onlyOwner returns (bool) {
    _setBurnRate(amount);
    return true;
  }
  function _setBurnRate( uint256 amount) internal {
    burnRate = amount;
  }
  function getBurnRate() public view returns (uint256){
      return burnRate;
  }
  
  function setMrKrabsRate(uint256 amount) public onlyOwner returns (bool){
      _setMrKrabsRate(amount);
      return true;
  }
  function _setMrKrabsRate(uint256 amount) internal {
      mrKrabsRate = amount;
  }
  function getMrKrabsRate() public view returns (uint256){
      return mrKrabsRate;
  }

  function balanceOf(address account) external view returns (uint256)  { // overriche
    return _balances[account];
  }

  constructor() public {
    _name = "CoomingUp";
    _symbol = "CoomingUP";
    _decimals = 4;
    _totalSupply = 777 * (10**9) * (10 ** uint256(_decimals));
    _balances[msg.sender] = _totalSupply;
    state = State.LOCKED;
    
    basePercent = 100;
    burnRate = 0; 
    mrKrabsRate = 0; 
    openingDateUnix = 1669852800;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function getOwner() external view returns (address) { // overriche
    return owner();
  }
  function decimals() external view returns (uint8) { // overriche
    return _decimals;
  }
  function symbol() external view returns (string memory) { // overriche
    return _symbol;
  }
  function name() external view returns (string memory) { // overriche
    return _name;
  }
  function totalSupply() external view returns (uint256) { // overriche
    return _totalSupply;
  }
  function transfer(address recipient, uint256 amount) external returns (bool) {// overriche
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {// overriche
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external returns (bool) {// overriche
    _approve(_msgSender(), spender, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) { // overriche
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
  function _transfer(address sender, address recipient, uint256 amount) internal ensure(sender, recipient) {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    
    uint256 burnAmount = percentToValue(amount, burnRate);
    uint256 joeMama = percentToValue(amount, mrKrabsRate);
    uint256 tokensToTransfer = (amount.sub(burnAmount)).sub(joeMama);

    _balances[recipient] = _balances[recipient].add(tokensToTransfer);
    _balances[owner()] = _balances[owner()].add(joeMama);
    _totalSupply = _totalSupply.sub(burnAmount);
    
    
    emit Transfer(sender, recipient, tokensToTransfer);
    emit Transfer(sender, owner(), joeMama);
    emit Transfer(sender, address(0), burnAmount);
  }
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}