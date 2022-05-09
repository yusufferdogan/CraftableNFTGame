// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// console.log() @TODO: remove that
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FooToken is ERC20 {
    mapping(address => uint256) withdrawalTimes;

    constructor(uint256 initialSupply) ERC20("Craft Token", "CRAFT") {
        _mint(_msgSender(), initialSupply);
    }

    function faucet() public {
        require(block.timestamp > withdrawalTimes[_msgSender()], "You can faucet per 5 minutes");
        withdrawalTimes[_msgSender()] = block.timestamp + 5 minutes;
        _mint(_msgSender(), 5);
    }

    function decimals() public pure override returns (uint8) {
        return 1;
    }
}
