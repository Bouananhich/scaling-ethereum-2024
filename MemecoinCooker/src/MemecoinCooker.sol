// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IFactory} from "./IFactory.sol";
import {IUniswapV2Factory} from "../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Pair} from "../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract MemecoinCooker {
    address _token_factory_contract;
    address _owner;
    address _uniswap_v2_router_address;
    mapping(address => address) public _memecoin_to_pair;
    mapping(address => uint256) public _memecoin_to_timestamp;
    uint256 constant _liquidity_lock_duration = 30 days;

    event MemecoinCreated(address memecoin, address owner);

    event MemecoinDeployed(address memecoin, address pair);

    constructor(address myfactoryContract) {
        _owner = msg.sender;
        _token_factory_contract = myfactoryContract;
    }

    function setUniswapv2Router(address myUniswapRouterAddress) public {
        require(msg.sender == _owner, "Only owner can set uniswap factory");
        _uniswap_v2_router_address = myUniswapRouterAddress;
    }

    function MemecoinCookerOwner() public view returns (address) {
        return _owner;
    }

    function tokenFactoryContract() public view returns (address) {
        return _token_factory_contract;
    }

    function uniswapv2RouterAddress() public view returns (address) {
        return _uniswap_v2_router_address;
    }

    function isTokenFromMemecoinCooker(address token) public view returns (bool) {
        return IFactory(_token_factory_contract).token2Deployed(token);
    }

    function remainingLiquidityLockTime(address memecoin_address) public view returns (uint256) {
        require(_memecoin_to_pair[memecoin_address] != address(0), "Pair not found");
        uint256 timestamp = _memecoin_to_timestamp[memecoin_address];
        if (block.timestamp > timestamp + _liquidity_lock_duration) {
            return 0;
        }
        return timestamp + _liquidity_lock_duration - block.timestamp;
    }

    function cookMemecoin(string memory name, string memory symbol, uint256 totalSupply) public returns (address) {
        IFactory factory = IFactory(_token_factory_contract);
        address memecoin_address = factory.issueToken(name, symbol, totalSupply, msg.sender);
        emit MemecoinCreated(memecoin_address, msg.sender);
        return memecoin_address;
    }

    function deploy_on_uniswapv2(address memecoin_address, uint256 memecoin_amount) public payable {
        require(_uniswap_v2_router_address != address(0), "Uniswap router address not set");

        IFactory factory = IFactory(_token_factory_contract);
        require(msg.sender == factory.token2Owner(memecoin_address), "Only token owner can deploy the token");

        IERC20 memecoin = IERC20(memecoin_address);
        require(memecoin.approve(_uniswap_v2_router_address, memecoin_amount), "Approval failed");
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(_uniswap_v2_router_address);
        address uniswap_factory = uniswapRouter.factory();
        address weth = uniswapRouter.WETH();
        address pair = IUniswapV2Factory(uniswap_factory).createPair(memecoin_address, weth);
        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = uniswapRouter.addLiquidityETH{value: msg.value}(
            memecoin_address, memecoin_amount, 0, 0, address(this), block.timestamp
        );
        _memecoin_to_pair[memecoin_address] = pair;
        _memecoin_to_timestamp[memecoin_address] = block.timestamp;
        emit MemecoinDeployed(memecoin_address, pair);
    }

    function unlockLiquidity(address memecoin_address) public returns (bool) {
        require(_uniswap_v2_router_address != address(0), "Uniswap router address not set");
        require(_memecoin_to_pair[memecoin_address] != address(0), "Pair not found");
        require(
            msg.sender == IFactory(_token_factory_contract).token2Owner(memecoin_address),
            "Only owner can unlock liquidity"
        );
        require(remainingLiquidityLockTime(memecoin_address) == 0, "Liquidity lock time not over");
        address pair = _memecoin_to_pair[memecoin_address];
        IERC20(pair).transfer(msg.sender, IERC20(pair).balanceOf(address(this)));
        return true;
    }

    receive() external payable {}

    fallback() external payable {}
}
