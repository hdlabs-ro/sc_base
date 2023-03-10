// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILog {
    /**
     * @dev Developer dev only messages
     */
    event Log(string indexed msg);
    event LogBytes(bytes indexed msg);
    event LogBool(bool indexed msg);
}
