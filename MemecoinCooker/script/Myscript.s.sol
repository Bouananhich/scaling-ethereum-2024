// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/TokenFactory.sol";
import "../src/MemecoinCooker.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        TokenFactory factory = new TokenFactory();
        MemecoinCooker cooker = new MemecoinCooker(address(factory));
        factory.setAdminContract(address(cooker));
        cooker.setUniswapv2Router(address(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008));
        vm.stopBroadcast();
    }
}
