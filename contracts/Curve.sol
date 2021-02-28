// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./BondedToken.sol";

contract Curve is Ownable {
    using SafeMath for uint256;

    BondedToken internal bondedToken_;
    IERC20 internal collateralToken_;

    bool internal isInitialised_;
    bool internal alive_;


    //------------------------------------------------------------------------
    // Modifiers
    //------------------------------------------------------------------------

    modifier isUsable() {
        require(
            isInitialised_ && alive_,
            "Contract is not usable"
        );
        _;
    }

    //------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------

    constructor(
        address _bondedToken,
        address _collateralToken
    ) {
        bondedToken_ = BondedToken(_bondedToken);
        collateralToken_ = IERC20(_collateralToken);
        isInitialised_ = false;
    }

    //------------------------------------------------------------------------
    // View
    //------------------------------------------------------------------------

    function buyCost(uint256 _amount) public view returns(uint256) {
        return (
            areaAtSupply(bondedToken_.totalSupply().add(_amount)) - 
            areaAtSupply(bondedToken_.totalSupply())
        );
    }

    function sellReward(uint256 _amount) public view returns(uint256) {
        return (
            areaAtSupply(bondedToken_.totalSupply()) - 
            areaAtSupply(bondedToken_.totalSupply().sub(_amount))
        );
    }

    //------------------------------------------------------------------------
    // Public
    //------------------------------------------------------------------------

    function init() public {
        require(
            bondedToken_.isMinter(address(this)),
            "Curve must be minter"
        );
        alive_ = true;
        isInitialised_ = true;
    }

    function mint(uint256 _amount) public isUsable() returns(bool) {
        // get the cost
        uint256 cost = buyCost(_amount);
        // take their money 
        require(
            collateralToken_.transferFrom(
                msg.sender,
                address(this),
                cost
            ),
            "Transfer failed :("
        );
        // Send them bonded tokens
        require(
            bondedToken_.mintTo(msg.sender, _amount),
            "Mint Failed"
        );
        // return success 
        return true;
    }

    function burn(uint256 _amount) public isUsable() returns(bool) {
        // get the reward
        uint256 reward = sellReward(_amount);
        // burn their tokens
        require(
            bondedToken_.burnFrom(msg.sender, _amount),
            "Burn failed"
        );
        // send them money
        require(
            collateralToken_.transfer(
                msg.sender,
                reward
            ),
            "Transfer failed :("
        );
        // return success
        return true;
    }

    function shutDown() public onlyOwner() {
        alive_ = false;
        // remove curve as minter
        bondedToken_.removeMinter(address(this));
    }

    //------------------------------------------------------------------------
    // Internal
    //------------------------------------------------------------------------

    function areaAtSupply(uint256 _supply) internal pure returns(uint256) {
        uint256 pow = _supply**3;
        require(
            pow > _supply,
            "Overflow"
        );
        return pow.div(3);
    }

}