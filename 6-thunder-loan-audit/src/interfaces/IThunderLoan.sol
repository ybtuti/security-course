// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// @audit-info the IThunderLoan contract should be implimented by the Thunder Loan contract!
interface IThunderLoan {
    // @audit-info/low ????
    function repay(address token, uint256 amount) external;
}
// ✅
