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
    mapping (address => address) public _memecoin_to_LP_token;

    constructor(address myfactoryContract) {
        _owner = msg.sender;
        _token_factory_contract = myfactoryContract;
    }

    function setUniswapv2Router(address myUniswapRouterAddress) public {
        require(msg.sender == _owner, "Only owner can set uniswap factory");
        _uniswap_v2_router_address = myUniswapRouterAddress;
    }

    function setFactoryContract(address myTokenFactoryContract) public {
        require(msg.sender == _owner, "Only owner can set factory contract");
        _token_factory_contract = myTokenFactoryContract;
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

    function cookMemecoin(string memory name, string memory symbol, uint256 totalSupply) public returns (address) {
        IFactory factory = IFactory(_token_factory_contract);
        return factory.issueToken(name, symbol, totalSupply, msg.sender);
    }

    function deploy_on_uniswapv2(address memecoin_address, uint256 memecoin_amount) public payable {
        require(_uniswap_v2_router_address != address(0), "Uniswap factory not set");

        IFactory factory = IFactory(_token_factory_contract);
        require(msg.sender == factory.token2Owner(memecoin_address), "Only token owner can deploy the token");
        
        IERC20 memecoin = IERC20(memecoin_address);
        require(memecoin.approve(_uniswap_v2_router_address, memecoin_amount), "Approval failed");
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(_uniswap_v2_router_address);
        address uniswap_factory = uniswapRouter.factory();
        address weth = uniswapRouter.WETH();
        address pair = IUniswapV2Factory(uniswap_factory).createPair(memecoin_address, weth);
        (uint amountToken, uint amountETH, uint liquidity) = uniswapRouter.addLiquidityETH{value: msg.value}(memecoin_address, memecoin_amount, 0, 0, address(this), block.timestamp);
        require(liquidity > 0, "Liquidity not added");
        //address pair = IUniswapV2Factory(uniswapRouter.factory()).getPair(address(memecoin), uniswapRouter.WETH());
        //_memecoin_to_LP_token[memecoin_address] = pair;
    }

    receive() external payable {}

    fallback() external payable {}

}