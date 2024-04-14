// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IFactory} from "./IFactory.sol";

contract MemecoinCooker {

    address _factoryContract;
    address _owner;

    constructor(address myfactoryContract) {
        _owner = msg.sender;
        _factoryContract = myfactoryContract;
    }

    function setFactoryContract(address myfactoryContract) public {
        require(msg.sender == _owner, "Only owner can set factory contract");
        _factoryContract = myfactoryContract;
    }

    function MemecoinCookerOwner() public view returns (address) {
        return _owner;
    }

    function factoryContract() public view returns (address) {
        return _factoryContract;
    }

    function cookMemecoin(string memory name, string memory symbol, uint256 totalSupply) public returns (address) {
        IFactory factory = IFactory(_factoryContract);
        return factory.issueToken(name, symbol, totalSupply, msg.sender);
    }

}