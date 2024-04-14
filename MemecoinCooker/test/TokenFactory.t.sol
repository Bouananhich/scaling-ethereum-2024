// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract User {
}

contract Admin{
}

contract TokenFactoryTest is Test{
    TokenFactory public factory;
    User public user; 
    Admin public admin;
    IERC20 public token;

    address public ownerAddress; 
    address public myTokenAddress;
    address public adminAddress;
    address public userAddress;

    function setUp() public {
        factory = new TokenFactory();
        user = new User();
        admin = new Admin();
        adminAddress = address(admin);
        userAddress = address(user);
        ownerAddress = address(this);
    }

    function testOwner() public {
        bool _isOwner = (factory.factoryOwner() == ownerAddress);
        assertEq(_isOwner, true, "Owner should be the contract creator");
    }

    function testSetAdmin() public {
        factory.setAdminContract(adminAddress);
        bool _isAdmin = (factory.adminContract() == adminAddress);
        assertEq(_isAdmin, true, "Admin should be set");
    }

    function testIssueToken() public {
        factory.setAdminContract(ownerAddress);
        myTokenAddress = factory.issueToken("Mytoken", "MTK", 100, userAddress);
        bool _isOwner = (factory.token2Owner(myTokenAddress) == userAddress);
        assertEq(_isOwner, true, "Token ownership should be set to user");
        token = IERC20(myTokenAddress);
        bool _isBalanceCorrect = (token.balanceOf(ownerAddress) == 100);
        assertEq(_isBalanceCorrect, true, "Admin should have 100 tokens");
    }

}