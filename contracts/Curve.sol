// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BondedToken.sol";

contract Curve is Ownable {
    using SafeMath for uint256;

    BondedToken internal bondedToken_;
    IERC20 internal collateralToken_;

    bool internal isInitialised_;
    bool internal isAlive;

    modifier isUsable() {
        require(
            isInitialised_ && isAlive,
            "Curve is unusable"
        );
        _;
    }

    constructor(
        address _bondedToken,
        address _collateralToken
    ) 
    {
        bondedToken_ = BondedToken(_bondedToken);
        collateralToken_ = IERC20(_collateralToken);
        isInitialised_ = false;
        isAlive = true;
    }

    /**
     * @param   _amount Is the amount of Bonded Tokens to be bought. 
     * @return  Cost in collateral for the amount of bonded tokens.
     */
    function buyCost(uint256 _amount) public view returns(uint256) {
        return (
            areaAtSupply(bondedToken_.totalSupply().add(_amount)) -
            areaAtSupply(bondedToken_.totalSupply())
        );
    }

    function initialised() public {
        require(
            bondedToken_.isMinter(address(this)),
            "Curve is not minter"
        );
        isInitialised_ = true;
    }

    function sellReward(uint256 _amount) public view returns(uint256) {
        return (
            areaAtSupply(bondedToken_.totalSupply()) -
            areaAtSupply(bondedToken_.totalSupply().sub(_amount))
        );
    }

    function mint(uint256 _amount) public isUsable() returns(bool) {
        // Get the cost of the amount
        uint256 cost = buyCost(_amount);
        // Take their money
        require(
            collateralToken_.transferFrom(msg.sender, address(this), cost),
            "Transfer From failed :("
        );
        // Send them bonded tokens
        require(
            bondedToken_.mintTo(msg.sender, _amount),
            "Mint failed :("
        );
        // Return success 
        return true;
    }

    function burn(uint256 _amount) public isUsable() returns(bool) {
        // Get the reward for the amount
        uint256 reward = sellReward(_amount);
        // Burn their tokens
        require(
            bondedToken_.burnFrom(msg.sender, _amount),
            "Burn failed :("
        );
        // Send them their money
        require(
            collateralToken_.transfer(msg.sender, reward),
            "Transfer failed :("
        );
        // Return success
        return true;
    }

    function shutDown() public onlyOwner() {
        require(
            bondedToken_.removeMinter(address(this)),
            "Failed to remove"
        );
        isAlive = false;
    }

    function areaAtSupply(uint256 _supply) internal pure returns(uint256) {
        uint256 pow = _supply**3;
        require(
            pow > _supply,
            "Overflow"
        );
        return pow.div(3);
    }
}