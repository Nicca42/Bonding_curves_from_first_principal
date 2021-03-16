// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BondedToken is ERC20, Ownable {
    mapping(address => bool) internal minters_;

    modifier isMinterOrOwner() {
        require(
            minters_[msg.sender] || msg.sender == owner(),
            "Don't have permission"
        );
        _;
    }

    constructor(string memory _name, string memory _symbol) 
    ERC20(_name, _symbol) {

    }

    function isMinter(address _minter) public returns(bool) {
        return minters_[_minter];
    }

    function addMinter(address _newMinter) public onlyOwner() returns(bool) {
        minters_[_newMinter] = true;
        return true;
    }

    function removeMinter(address _oldMinter) public isMinterOrOwner() returns(bool) {
        minters_[_oldMinter] = false;
        return true;
    }

    function mintTo(address _to, uint256 _amount) public isMinterOrOwner() returns(bool) {
        _mint(_to, _amount);
        return true;
    }

    function burnFrom(address _from, uint256 _amount) public isMinterOrOwner() returns(bool) {
        _burn(_from, _amount);
        return true;
    }
}