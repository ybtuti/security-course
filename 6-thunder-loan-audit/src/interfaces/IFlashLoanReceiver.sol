// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

// @audit-info: unused import
// It's bad practice to edit live code for tests/mock, we must remove the import from `MockFlashLoanReceiver.sol`
import { IThunderLoan } from "./IThunderLoan.sol";

/**
 * @dev Inspired by Aave:
 * https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/interfaces/IFlashLoanReceiver.sol
 */
interface IFlashLoanReceiver {
    // answered is the token the token thats being borrowed?
    // a yes
    // @audit where is the natspec??
    // qanswered amount is the amount of tokens?
    // yes
    function executeOperation(
        address token,
        uint256 amount,
        uint256 fee,
        address initiator,
        bytes calldata params
    )
        external
        returns (bool);
}

// ✅
