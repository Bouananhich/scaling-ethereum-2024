// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MemecoinCooker} from "../src/MemecoinCooker.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Router02} from "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IWETH} from "../lib/v2-periphery/contracts/interfaces/IWETH.sol";

contract MemecoinCookerTest is Test{
    MemecoinCooker cooker;
    TokenFactory factory;
    IUniswapV2Factory uniswapFactory;
    IUniswapV2Router02 uniswapRouter;
    IWETH public weth;

    function setUp() public {
        factory = new TokenFactory();
        cooker = new MemecoinCooker(address(factory));
        factory.setAdminContract(address(cooker));
        uniswapFactory = IUniswapV2Factory(deployCode("../lib/v2-core/contracts/UniswapV2Factory.sol",abi.encode(address(0))));
        weth = IWETH(deployCode("../lib/v2-periphery/contracts/WETH9.sol"));
        uniswapRouter = IUniswapV2Router02(deployCode("../lib/v2-periphery/contracts/UniswapV2Router02.sol",abi.encode(address(uniswapFactory), address(weth))));
        cooker.setUniswapv2Router(address(uniswapRouter));
        vm.deal(address(this),1 ether);
    }

    function testCookMemecoin() public {
        address mytokenAddress = cooker.cookMemecoin("My token", "MTK", 1000);
        bool isOwner = (factory.token2Owner(mytokenAddress) == address(this));
        assertEq(isOwner, true, "Token ownership should be set to user");
        bool isBalanceCorrect = (IERC20(mytokenAddress).balanceOf(address(cooker)) == 1000);
        assertEq(isBalanceCorrect, true, "Admin should have 1000 tokens");
    }

    function testDeployOnUniswapv2() public {
        address testTokenAddress = cooker.cookMemecoin("Test", "TST", 100);
        cooker.deploy_on_uniswapv2(testTokenAddress, 0.1 ether, 100);
        bool isLPDeployed = (uniswapFactory.getPair(testTokenAddress, address(weth)) != address(0));
        assertEq(isLPDeployed, true, "LP should be deployed");
        bool isLPTokenBalanceCorrect = (IERC20(uniswapFactory.getPair(testTokenAddress, address(weth))).balanceOf(address(cooker)) > 0);
    }
    
}