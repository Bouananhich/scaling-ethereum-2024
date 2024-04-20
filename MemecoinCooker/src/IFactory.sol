// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IFactory {
    function setAdminContract(address adminContract) external;
    function issueToken(string memory _name, string memory _symbol, uint256 _totalSupply, address _to) external returns (address);
    function factoryOwner() external view returns (address);
    function adminContract() external view returns (address);
    function token2Owner(address _token) external view returns (address);
    function token2Deployed(address _token) external view returns (bool);
}