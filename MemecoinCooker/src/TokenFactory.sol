// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract myToken is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, address _to) ERC20(_name, _symbol) {
        _mint(_to, _totalSupply);
    }
}

contract TokenFactory {
    address _owner;
    address _adminContract;
    mapping (address => address) _token2Owner;

    constructor() {
        _owner = msg.sender;
    }

    function setAdminContract(address myadminContract) public {
        require(msg.sender == _owner, "Only owner can set admin contract");
        _adminContract = myadminContract;
    }

    function issueToken(string memory _name, string memory _symbol, uint256 _totalSupply, address _to) public returns (address) {
        require(_adminContract != address(0), "Admin contract not set");
        require(msg.sender == _adminContract, "Only admin contract can issue token");
        myToken newToken = new myToken(_name, _symbol, _totalSupply, _adminContract);
        _token2Owner[address(newToken)] = _to;
        return address(newToken);
    }

    function factoryOwner() public view returns (address) {
        return _owner;
    }

    function adminContract() public view returns (address) {
        return _adminContract;
    }

    function token2Owner(address _token) public view returns (address) {
        return _token2Owner[_token];
    }
}