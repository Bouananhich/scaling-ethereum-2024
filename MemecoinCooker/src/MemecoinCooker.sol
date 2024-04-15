// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IFactory} from "./IFactory.sol";
import {IUniswapV2Factory} from "../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Pair} from "../lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract MemecoinCooker {

    address _factoryContract;
    address _owner;
    address _uniswapv2FactoryAddress;
    address _wethAddress;
    mapping (address => address) public _token2Pool;

    constructor(address myfactoryContract) {
        _owner = msg.sender;
        _factoryContract = myfactoryContract;
    }

    function setUniswapv2Factory(address myuniswapFactoryAddress) public {
        require(msg.sender == _owner, "Only owner can set uniswap factory");
        _uniswapv2FactoryAddress = myuniswapFactoryAddress;
    }

    function setFactoryContract(address myfactoryContract) public {
        require(msg.sender == _owner, "Only owner can set factory contract");
        _factoryContract = myfactoryContract;
    }

    function setWethAddress(address mywethAddress) public {
        require(msg.sender == _owner, "Only owner can set WETH address");
        _wethAddress = mywethAddress;
    }

    function wethAddress() public view returns (address) {
        return _wethAddress;
    }

    function MemecoinCookerOwner() public view returns (address) {
        return _owner;
    }

    function factoryContract() public view returns (address) {
        return _factoryContract;
    }

    function uniswapv2FactoryAddress() public view returns (address) {
        return _uniswapv2FactoryAddress;
    }

    function cookMemecoin(string memory name, string memory symbol, uint256 totalSupply) public returns (address) {
        IFactory factory = IFactory(_factoryContract);
        return factory.issueToken(name, symbol, totalSupply, msg.sender);
    }

    function deploy_on_uniswapv2(address memecoin_address, uint256 weth_amount) public {
        require(_uniswapv2FactoryAddress != address(0), "Uniswap factory not set");
        IFactory factory = IFactory(_factoryContract);
        require(msg.sender == factory.token2Owner(memecoin_address), "Only token owner can deploy the token");
        IERC20 weth = IERC20(_wethAddress);
        require(weth.allowance(msg.sender, address(this)) >= weth_amount, "Insufficient WETH allowance");
 
        createPair(memecoin_address);
        weth.transferFrom(msg.sender, address(this), weth_amount);
    }

    function createPair(address memecoin_address) internal returns (address) {
        IUniswapV2Factory uniswapFactory = IUniswapV2Factory(_uniswapv2FactoryAddress);
        address pair = uniswapFactory.createPair(memecoin_address, _wethAddress);
        _token2Pool[memecoin_address] = pair;
        return pair;
    }

}