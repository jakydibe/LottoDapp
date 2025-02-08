// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private storedValue;

    // Imposta un valore
    function set(uint256 _value) public {
        storedValue = _value;
    }

    // Ottiene il valore memorizzato
    function get() public view returns (uint256) {
        return storedValue;
    }
}

