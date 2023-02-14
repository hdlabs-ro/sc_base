// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ILogger {
    function LogString(
        string calldata file,
        string calldata method,
        string calldata key,
        string calldata message
    ) external;
}

contract TestLogger {
    function LogString() external {
        address loggerAddress = 0xD0DA387609Adc13779badAf1315a4904CD40976E;

        ILogger(loggerAddress).LogString("TestLogger.sol", "TestLogger", "k", "Alin");
        ILogger(loggerAddress).LogString("TestLogger.sol", "TestLogger", "k", loggerAddress);
        ILogger(loggerAddress).LogString("TestLogger.sol", "TestLogger", "k", 1980);
        ILogger(loggerAddress).LogString("TestLogger.sol", "TestLogger", "k", "ceva");
    }
}
