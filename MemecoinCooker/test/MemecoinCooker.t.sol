// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MemecoinCooker} from "../src/MemecoinCooker.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MemecoinCookerTest is Test{
    MemecoinCooker cooker;
    TokenFactory factory;

    function setUp() public {
        factory = new TokenFactory();
        cooker = new MemecoinCooker(address(factory));
        factory.setAdminContract(address(cooker));
    }

    function testMemecoinCooker() public {
        address mytokenAddress = cooker.cookMemecoin("My token", "MTK", 1000);
        bool isOwner = (factory.token2Owner(mytokenAddress) == address(this));
        assertEq(isOwner, true, "Token ownership should be set to user");
        bool isBalanceCorrect = (IERC20(mytokenAddress).balanceOf(address(cooker)) == 1000);
        assertEq(isBalanceCorrect, true, "Admin should have 1000 tokens");
    }

}