// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Logger {
    int private _x = 193744;
    uint256 private _balance = 9999999999991000000000000000000000000;
    address private _addr = 0x49CbBE6c1B8C8DC1cDB5700C5853173eeE5DC070;

    event LogString(string key,string value);
    event LogInt(string key,int value);
    event LogUint256(string key,uint256 value);
    event LogAddress(string key,address value);

    constructor() {}

    function Demo() external returns (bool) {
        emit LogString("p1","Start method");
        emit LogString("longString","Aici o sa incerc sa bag o fraza sau ceva asemanator mai lung otricum");
        emit LogAddress("address",_addr);
        emit LogUint256("uint256",_balance);
        emit LogInt("int",_x);
        return true;
    }
}
