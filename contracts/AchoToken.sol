// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AchoToken is ERC20, Ownable {
    constructor(
        uint256 initialSupply,
        address initialOwner
    ) ERC20("AchoToken", "ACHO") Ownable(initialOwner) {
        _mint(initialOwner, initialSupply * (10 ** decimals())); // Mint initial supply
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
