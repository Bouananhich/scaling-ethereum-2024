// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MemecoinCooker} from "../src/MemecoinCooker.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IUniswapV2Router02} from "../lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "../lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IWETH} from "./IWETH.sol";

contract MemecoinCookerTest is Test {
    MemecoinCooker cooker;
    TokenFactory factory;
    IUniswapV2Factory uniswapFactory;
    IUniswapV2Router02 uniswapRouter;
    IWETH public weth;

    function setUp() public {
        factory = new TokenFactory();
        cooker = new MemecoinCooker(address(factory));
        factory.setAdminContract(address(cooker));
        // uniswapFactory = IUniswapV2Factory(deployCode("UniswapV2Factory.sol", abi.encode(address(0))));
        // weth = IWETH(deployCode("WETH9.sol"));
        // uniswapRouter =
        //     IUniswapV2Router02(deployCode("UniswapV2Router02.sol", abi.encode(address(uniswapFactory), address(weth))));
        // cooker.setUniswapv2Router(address(uniswapRouter));
        // vm.deal(address(this), 10 ether);
        testSetup();
    }

    function testSetup() internal {
        // assertEq(uniswapRouter.WETH(), address(weth), "WETH address should be set in Uniswap router");
        // assertEq(uniswapRouter.factory(), address(uniswapFactory), "Factory address should be set in Uniswap router");
        // assertEq(address(this).balance, 10 ether, "Balance should be 10 ether");
        // assertEq(
        //     cooker.uniswapv2RouterAddress(),
        //     address(uniswapRouter),
        //     "Uniswap router address should be set in MemecoinCooker"
        // );
    }

    function testCookMemecoin() public {
        address mytokenAddress = cooker.cookMemecoin("My token", "MTK", 1000);
        bool isOwner = (factory.token2Owner(mytokenAddress) == address(this));
        assertEq(isOwner, true, "Token ownership should be set to user");
        bool isBalanceCorrect = (IERC20(mytokenAddress).balanceOf(address(cooker)) == 1000);
        assertEq(isBalanceCorrect, true, "Admin should have 1000 tokens");
        bool isTokenFromMemecoinCooker = cooker.isTokenFromMemecoinCooker(mytokenAddress);
        assertEq(isTokenFromMemecoinCooker, true, "Token should be from MemecoinCooker");
    }

    function _test_Weth() public {
        weth.deposit{value: 0.5 ether}();
        assertEq(weth.balanceOf(address(this)), 0.5 ether, "WETH balance should be 0.5 ether");
        weth.withdraw(0.5 ether);
        assertEq(weth.balanceOf(address(this)), 0 ether, "WETH balance should be 0 ether");
    }

    // This test requires deploying a local uniswapv2 factory and router which requires a small change in the code of UniswapV2Library in the pairFor function.
    // function testDeployOnUniswapv2() public {
    //     _test_Weth();
    //     address testTokenAddress = cooker.cookMemecoin("Test", "TST", 1000 * 1e18);
    //     address[] memory adresses = new address[](1);
    //     adresses[0] = address(this);
    //     uint256[] memory amounts = new uint256[](1);
    //     amounts[0] = 10 * 1e18;
    //     cooker.deploy_on_uniswapv2{value: 0.5 ether}(testTokenAddress, adresses, amounts);
    //     bool isLPDeployed = (uniswapFactory.getPair(testTokenAddress, address(weth)) != address(0));
    //     assertEq(isLPDeployed, true, "LP should be deployed");
    //     bool isLPTokenBalanceCorrect =
    //         (IERC20(uniswapFactory.getPair(testTokenAddress, address(weth))).balanceOf(address(cooker)) > 0);
    //     assertEq(isLPTokenBalanceCorrect, true, "LP token balance should be greater than 0");
    //     bool isLiquidityLocked = (cooker.remainingLiquidityLockTime(testTokenAddress) > 0);
    //     assertEq(isLiquidityLocked, true, "Liquidity should be locked");
    //     vm.warp(block.timestamp + 30 days);
    //     bool isLiquidityUnlocked = (cooker.remainingLiquidityLockTime(testTokenAddress) == 0);
    //     assertEq(isLiquidityUnlocked, true, "Liquidity should be unlocked");
    //     bool isLiquidityReturned = cooker.unlockLiquidity(testTokenAddress);
    //     assertEq(isLiquidityReturned, true, "Liquidity should be returned");
    //     bool isMemecoinCookerLPTokenBalanceZero =
    //         (IERC20(uniswapFactory.getPair(testTokenAddress, address(weth))).balanceOf(address(cooker)) == 0);
    //     assertEq(isMemecoinCookerLPTokenBalanceZero, true, "MemecoinCooker's LP balance should be 0");
    //     bool isUserLPTokenBalanceCorrect =
    //         (IERC20(uniswapFactory.getPair(testTokenAddress, address(weth))).balanceOf(address(this)) > 0);
    //     assertEq(isUserLPTokenBalanceCorrect, true, "User's LP balance should be greater than 0");
    //     bool isMemecoinBalanceSet = (IERC20(testTokenAddress).balanceOf(address(this)) == 10 * 1e18);
    //     assertEq(isMemecoinBalanceSet, true, "Memecoin balance should be set");
    // }

    receive() external payable {}

    fallback() external payable {}
}
