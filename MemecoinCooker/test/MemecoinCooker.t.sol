// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MemecoinCooker} from "../src/MemecoinCooker.sol";

contract MemecoinCookerTest is Test{
    MemecoinCooker cooker;

    function setUp() public {
        cooker = new MemecoinCooker();
    }

    function testMemecoinCooker() public view {
        console.log("MemecoinCooker address: ", address(cooker));
    }

}