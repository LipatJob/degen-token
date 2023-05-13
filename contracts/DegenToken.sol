// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// Your task is to create a ERC20 token and deploy it on the Avalanche network for Degen Gaming. The smart contract should have the following functionality:
contract DegenToken is ERC20, Ownable, ERC20Burnable {
    constructor() ERC20("Degen", "DGN") {}

    event StoreItemRedeemed(address user, uint256 itemId);

    function toActualUnit(uint256 amount) private view returns (uint256) {
        return amount * 10**decimals();
    }

    function toBaseUnit(uint256 amount) private view returns (uint256) {
        return amount / 10**decimals();
    }

    // 1. Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, toActualUnit(amount));
    }

    // 2. Transferring tokens: Players should be able to transfer their tokens to others.
    function transfer(address reciever, uint256 amount)
        public
        override
        returns (bool)
    {
        uint256 actualAmount = toActualUnit(amount);
        require(
            balanceOf(msg.sender) >= actualAmount,
            "You don't have enough degen Tokens"
        );
        return super.transfer(reciever, actualAmount);
    }

    // 3. Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
    function redeemStoreItem(uint256 itemId) public {
        uint256 cost = 0;
        if (itemId == 1) {
            cost = 50;
        } else if (itemId == 2) {
            cost = 100;
        } else if (itemId == 3) {
            cost = 150;
        } else {
            revert("Please input a valid itemId");
        }
        uint256 actualCost = toActualUnit(cost);
        require(
            balanceOf(msg.sender) >= actualCost,
            "You don't have enough tokens to redeem the store item"
        );
        transfer(owner(), cost);
        emit StoreItemRedeemed(msg.sender, itemId);
    }

    function getStoreItems() public pure returns (string[3] memory) {
        return [
            "1 - Pin - 50 DGN",
            "2 - Poster - 100 DGN",
            "3 - Jacket - 150 DGN"
        ];
    }

    // 4. Checking token balance: Players should be able to check their token balance at any time.
    function getBalance() public view returns (uint256) {
        return toBaseUnit(this.balanceOf(msg.sender));
    }

    // 5. Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
    function burn(uint256 amount) public override {
        uint256 actualAmount = toActualUnit(amount);
        require(
            balanceOf(msg.sender) >= actualAmount,
            "You don't have enough degen Tokens"
        );
        super.burn(actualAmount);
    }
}
