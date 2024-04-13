// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract myToken is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, address _to) ERC20(_name, _symbol) {
        _mint(_to, _totalSupply);
    }
}

contract TokenFactory {
    address public owner;
    address public adminContract;
    mapping (address => address) public token2Owner;

    constructor() {
        owner = msg.sender;
    }

    function setAdminContract(address _adminContract) public {
        require(msg.sender == owner, "Only owner can set admin contract");
        adminContract = _adminContract;
    }

    function issueToken(string memory _name, string memory _symbol, uint256 _totalSupply, address _to) public returns (address) {
        require(msg.sender == adminContract, "Only admin contract can issue token");
        myToken newToken = new myToken(_name, _symbol, _totalSupply, adminContract);
        token2Owner[address(newToken)] = _to;
        return address(newToken);
    }
}