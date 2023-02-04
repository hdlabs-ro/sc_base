// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint256 storedData;

    function set(uint256 x) public {
        storedData = x;
    }

    function get() public view returns (uint256) {
        return storedData;
    }
}
//0xD0DA387609Adc13779badAf1315a4904CD40976E
//0xabb5e6f15401e2eee2ff83691d7248b646c00a2cd12a727668011f24a9d1d751
