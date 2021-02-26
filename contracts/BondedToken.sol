// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BondedToken is ERC20, Ownable {
    mapping(address => bool) internal minters_;

    modifier onlyMinter() {
        require(minters_[msg.sender], "Not minter");
        _;
    }

    modifier onlyMinterOrOwner() {
        require(
            minters_[msg.sender] || msg.sender == owner(),
            "Not minter"
        );
        _;
    }

    constructor(string memory _name, string memory _symbol)
    ERC20(_name, _symbol) 
    {} 

    function isMinter(address _minter) public view returns(bool) {
        return minters_[_minter];
    }

    function addMinter(address _newMiner) public onlyOwner() {
        minters_[_newMiner] = true;
    }

    function removeMinter(address _minter) public  onlyMinterOrOwner() {
        minters_[_minter] = false;
    }

    function mintTo(
        address _to, 
        uint256 _amount
    ) 
        public 
        onlyMinter() 
        returns(bool) 
    {
        _mint(_to, _amount);
        return true;
    }

    function burnFrom(
        address _from,
        uint256 _amount
    )
        public 
        onlyMinter()
        returns(bool)
    {
        _burn(_from, _amount);
        return true;
    }
}