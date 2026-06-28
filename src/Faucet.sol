pragma solidity 0.8.26;

// SPDX-License-Identifier: GPL-3.0
// Our first contract is a faucet!

contract Faucet {
    // Give out ether to anyone who asks
    function withdraw(uint256 _withdrawAmount, address payable _to) public {
        // Limit withdrawal amount
        require(_withdrawAmount <= 100000000000000000);
        // Send the amount to the address that requested it
        _to.transfer(_withdrawAmount);
    }
    // Accept any incoming amount
    receive() external payable {}
}
