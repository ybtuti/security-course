---
title: Protocol Audit Report
author: 0xodus
date: March 7, 2023
header-includes:
  - \usepackage{titling}
  - \usepackage{graphicx}
---

\begin{titlepage}
    \centering
    \begin{figure}[h]
        \centering
        \includegraphics[width=0.5\textwidth]{logo.pdf} 
    \end{figure}
    \vspace*{2cm}
    {\Huge\bfseries TSwap Protocol Audit Report\par}
    \vspace{1cm}
    {\Large Version 1.0\par}
    \vspace{2cm}
    {\Large\itshape Cyfrin.io\par}
    \vfill
    {\large \today\par}
\end{titlepage}

\maketitle

<!-- Your report starts here! -->

Prepared by: [0xodus](https://0xodus.io)
Lead Auditors: 
- 0xodus

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
  - [High](#high)
    - [\[H-1\] Incorrect fee calculatin in `TSwapPool::getInputAmountBasedOnOutput` causes protocol to take too many tokens from users, resulting in lost fees](#h-1-incorrect-fee-calculatin-in-tswappoolgetinputamountbasedonoutput-causes-protocol-to-take-too-many-tokens-from-users-resulting-in-lost-fees)
    - [\[H-2\] Lack of slippage protection in `TSwapPool::swapExactOutput` causes users to potentially recieve way fewer tokens](#h-2-lack-of-slippage-protection-in-tswappoolswapexactoutput-causes-users-to-potentially-recieve-way-fewer-tokens)
    - [\[H-4\] `TSwapPool::sellPoolTokens` mismatches input and output tokens causig users to recieve the incorrect amount of tokens](#h-4-tswappoolsellpooltokens-mismatches-input-and-output-tokens-causig-users-to-recieve-the-incorrect-amount-of-tokens)
    - [\[H-5\] In `TSwapPool::_swap` the extra tokens given to users after every `swapCount` breaks the protocol invariant of `x * y = k`](#h-5-in-tswappool_swap-the-extra-tokens-given-to-users-after-every-swapcount-breaks-the-protocol-invariant-of-x--y--k)
  - [Medium](#medium)
    - [\[M-1\] TSwapPool::deposit is missing deadline check causing transactiond to complete even after the deadline](#m-1-tswappooldeposit-is-missing-deadline-check-causing-transactiond-to-complete-even-after-the-deadline)
    - [\[M-2\] Rebase, fee-on-transfer and ERC 777 tokens break protocol invariant](#m-2-rebase-fee-on-transfer-and-erc-777-tokens-break-protocol-invariant)
  - [Lows](#lows)
    - [\[L-1\] `TSwapPool::LiquidityAdded` event has parameters out of order](#l-1-tswappoolliquidityadded-event-has-parameters-out-of-order)
    - [\[L-2\] Default value returned by `TSwapPool::swapExactInput` results in incorrect return value give](#l-2-default-value-returned-by-tswappoolswapexactinput-results-in-incorrect-return-value-give)
  - [Informationals](#informationals)
    - [\[I-1\] `PoolFactory::PoolFactory__PoolDoesNotExist` is not used and should be removed](#i-1-poolfactorypoolfactory__pooldoesnotexist-is-not-used-and-should-be-removed)
    - [\[I-2\] Lacking zero address checks](#i-2-lacking-zero-address-checks)
    - [\[I-3\] `PoolFactory::createPool` should use `.symbol()` instead of `.name()`](#i-3-poolfactorycreatepool-should-use-symbol-instead-of-name)
    - [\[I-4\] Event is missing `indexed` fields](#i-4-event-is-missing-indexed-fields)

# Protocol Summary

This project is meant to be a permissionless way for users to swap assets between each other at a fair price. You can think of T-Swap as a decentralized asset/token exchange (DEX). 
T-Swap is known as an [Automated Market Maker (AMM)](https://chain.link/education-hub/what-is-an-automated-market-maker-amm) because it doesn't use a normal "order book" style exchange, instead it uses "Pools" of an asset. 
It is similar to Uniswap. To understand Uniswap, please watch this video: [Uniswap Explained](https://www.youtube.com/watch?v=DLu35sIqVTM)

# Disclaimer

The 0xodus team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 
## Scope 
## Roles
# Executive Summary
## Issues found
| Severtity | Number of issues found |
| --------- | ---------------------- |
| High      | 5                      |
| Medium    | 2                      |
| Low       | 2                      |
| Info      | 9                      |
| Total     | 18                     |
# Findings
## High

### [H-1] Incorrect fee calculatin in `TSwapPool::getInputAmountBasedOnOutput` causes protocol to take too many tokens from users, resulting in lost fees

**Description:** The `getInputamountBasedOnOutput` function is intended to calculate the amount of tokens the user should deposit given an amount of tokens of output tokens. However, the fuction currently miscalculates the resulting amount. When calculating the fee, it scales the amount by 10_000 insted of 1_000.

**Impact:** Protocol takes more fee than expected from users

**Recommended Mitigation:** 
```diff
    function getInputAmountBasedOnOutput(
        uint256 outputAmount,
        uint256 inputReserves,
        uint256 outputReserves
    )
        public
        pure
        revertIfZero(outputAmount)
        revertIfZero(outputReserves)
        returns (uint256 inputAmount)
    {
-        return ((inputReserves * outputAmount) * 10000) / ((outputReserves - outputAmount) * 997);
+        return ((inputReserves * outputAmount) * 1000) / ((outputReserves - outputAmount) * 997);

    }
```

### [H-2] Lack of slippage protection in `TSwapPool::swapExactOutput` causes users to potentially recieve way fewer tokens

**Description:** The `swapExactOutput` function does not include sort of any slippage protection. This function is similar to what is done in `TSwapPool::swapExactInput`, where the function should specify a `maxInputAmount`.

**Impact:** If market conditions change before the transaction process, the user could get a much worse swap.

**Proof of Concept:**
1. The price of WETH is 1,000 USDC
2. User inputs a `swapExactOutput` looking for 1 WETH 
   1. inputToken = USDC
   2. outputToken = WETH
   3. outputAmount = 1
   4. deadline = whatever
3. The function doesn't offer a maxInput amount
4. As the transaction is pending i the mempool, the market changes! And the price moves HUGE -> 1 WETH is now 10,000 USDC. 10x more than the user expected
5. The transaction completes, but the user sent the protocol 10,000 USDC instead of the expected 1,000 USDC

<!-- Write a PoC -->

**Recommended Mitigation:** We should include a `maxInputAmount` so the user only has to spend up to a specific amount, and can predict how much they will spend on the protocol.

```diff
    function swapExactOutput(
        IERC20 inputToken,
+       uint256 maxInputAmount,
.
.
.
        inputAmount = getInputAmountBasedOnOutput(outputAmount, inputReserves, outputReserves);
+       if(inputAmount > maxInputAmount){
+           revert();
+       }
        _swap(inputToken, inputAmount, outputToken, outputAmount);
```

### [H-4] `TSwapPool::sellPoolTokens` mismatches input and output tokens causig users to recieve the incorrect amount of tokens

**Description:** The `sellPoolTokens` function is intended to allow users to easily sell pool tokens and recieve WETH in exchange. Users indicate how many pool tokens they're willing to sell in the `poolTokenAmount` parameter. However, the function currently miscalculates the swapped amount.

This is due to the fact that the `swapexactOutput` function is called, whereas the `swapExactinput` function is the one that should be called.Because users specify the exact amount of input tokens, not  output.

**Impact:**  Users will swap the wrong amount of tokens, which is a severe disruption of protocol functionality.

**Proof of Concept:**
<!-- Write a PoC -->

**Recommended Mitigation:** 

Consider changing the implementation to use `swapExactInput` instead of `swapExactOutput`. Note that this would also require changing the `sellPoolTokens` function to accept a new parameter (ie `minWethToRecieve` to be passed to `swapExactInput`)

```diff
    function sellPoolTokens(
        uint256 poolTokenAmount,
+       uint256 minWethToRecieve        
        ) external returns (uint256 wethAmount) {
-        return swapExactOutput(i_poolToken, i_wethToken, poolTokenAmount, uint64(block.timestamp));
+        return swapExactInput(i_poolToken, poolTokenAmount, i_wethToken, minWethToRecieve, uint64(block.timestamp));

    }
```
Additionally, it might be wise to add a deadline to the function, as there is currently no deadline. MEV later

### [H-5] In `TSwapPool::_swap` the extra tokens given to users after every `swapCount` breaks the protocol invariant of `x * y = k`

**Description:** The protocol follows a strict invariance of `x * y = k`. Where:
- `x`: The balance of the pool token
- `y`: The balance of WETH
- `k`: The constant product of the two balances

This means, that whenever the balances change in the protocol, the ratio between the two amounts should remain constant, hence the `k`. However, this is broken due to the extra incentive in the `_swap` function. Meaning that over time the protocol funds will be drained.

The following block of code is responsible for the issue
```javascript
        swap_count++;
        // fee on Transfer
        if (swap_count >= SWAP_COUNT_MAX) {
            swap_count = 0;
            outputToken.safeTransfer(msg.sender, 1_000_000_000_000_000_000);
        }
```

**Impact:** A user may drain the protocol of funds by doing alot of swaps and collecting the extra incentive given out by the protocol.

More simply put, the protocols core invariant is broken

**Proof of Concept:**
1. the user swaps 10 times and collects the extra incentive of `1_000_000_000_000_000_000` tokens
2. That user continues to swap until all the protocols funds are drained

<details>
<summary>Proof of code</summary>

Place the following into `TSwapPool.t.sol` 

```javascript
    function testInvariantBroken() public {
        vm.startPrank(liquidityProvider);
        weth.approve(address(pool), 100e18);
        poolToken.approve(address(pool), 100e18);
        pool.deposit(100e18, 100e18, 100e18, uint64(block.timestamp));
        vm.stopPrank();

        uint256 outputWeth = 1e17;

        vm.startPrank(user);
        poolToken.approve(address(pool), type(uint256).max);
        poolToken.mint(user, 100e18);
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));

        int256 startingY = int256(weth.balanceOf(address(pool)));
        int256 expectedDeltaY = int256(-1) * int256(outputWeth);

        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));

        vm.stopPrank();

        uint256 endingY = weth.balanceOf(address(pool));
        int256 actualDeltaY = int256(endingY) - int256(startingY);

        assertEq(actualDeltaY, expectedDeltaY);
    }
```


</details>

**Recommended Mitigation:** Remove the extra incentive. If you want to keep this in, we should account for the change in x * y = k protocol invariant. Or, we should set aside the tokens in the same way we do with fees.

```diff
-        swap_count++;
-        // fee on Transfer
-        if (swap_count >= SWAP_COUNT_MAX) {
-            swap_count = 0;
-            outputToken.safeTransfer(msg.sender, 1_000_000_000_000_000_000);
-        }
```

## Medium

### [M-1] TSwapPool::deposit is missing deadline check causing transactiond to complete even after the deadline

**Description:** The `deposit` function accepts a deadline parameter, which according to the documentation is "The deadline The deadline for the transaction to be completed by". However, this parameter is never used. as a consequence, operations that add liquidity to the pool might be executed at expected times, in market conditions where the deposit rate is unfavourable.

<!-- MEV Attacks -->


**Impact:** Transactions could be sent when market conditions are unfavourable to deposit, even when adding a deadline parameter.

**Proof of Concept:** The `deadline` parameter is unused.

**Recommended Mitigation:** Consider making the following change to the function.

```diff
    function deposit(
        uint256 wethToDeposit,
        uint256 minimumLiquidityTokensToMint,
        uint256 maximumPoolTokensToDeposit,
        uint64 deadline
    )
        external
+       revertIfDeadlinePassed(deadline)
        revertIfZero(wethToDeposit)
        returns (uint256 liquidityTokensToMint)
    {
        if (wethToDeposit < MINIMUM_WETH_LIQUIDITY) {
            revert TSwapPool__WethDepositAmountTooLow(MINIMUM_WETH_LIQUIDITY, wethToDeposit);
        }
        if (totalLiquidityTokenSupply() > 0) {
            uint256 wethReserves = i_wethToken.balanceOf(address(this));
            uint256 poolTokenReserves = i_poolToken.balanceOf(address(this));

            if (maximumPoolTokensToDeposit < poolTokensToDeposit) {
                revert TSwapPool__MaxPoolTokenDepositTooHigh(maximumPoolTokensToDeposit, poolTokensToDeposit);
            }

            liquidityTokensToMint = (wethToDeposit * totalLiquidityTokenSupply()) / wethReserves;
            if (liquidityTokensToMint < minimumLiquidityTokensToMint) {
                revert TSwapPool__MinLiquidityTokensToMintTooLow(minimumLiquidityTokensToMint, liquidityTokensToMint);
            }
            _addLiquidityMintAndTransfer(wethToDeposit, poolTokensToDeposit, liquidityTokensToMint);
        } else {
            liquidityTokensToMint = wethToDeposit;
        }
    }
```

### [M-2] Rebase, fee-on-transfer and ERC 777 tokens break protocol invariant
<!-- 
**Description:** 

**Impact:** 

**Proof of Concept:**

**Recommended Mitigation:**  -->

## Lows

### [L-1] `TSwapPool::LiquidityAdded` event has parameters out of order

**Description:** When the `LiquidityAdded` event is emmitted in the `TSwapPool::_addLiquidityMintandTransfer` function, it logs values in an incorrect order. The `poolTokensToDeposit` value should go in the third parameter position, whereas the `wethToDeposit` value should go second.

**Impact:** Event emission is incorrect, leading to offchain functions potentally malfunctioning.


**Recommended Mitigation:** 

```diff
- emit LiquidityAdded(msg.sender, poolTokensToDeposit, wethToDeposit);
+ emit LiquidityAdded(msg.sender, wethToDeposit, poolTokensToDeposit);

```

### [L-2] Default value returned by `TSwapPool::swapExactInput` results in incorrect return value give

**Description:** The `swapExactInput` function is expected to return the actual amount of tokens by the caller. However, while it declares the named return value `output` it is never assigned a value, nor uses an explict return statement.

**Impact:** The return value wil always be 0, giving incorect information to the caller.

<!-- **Proof of Concept:** -->

**Recommended Mitigation:** 
```diff
    {
        uint256 inputReserves = inputToken.balanceOf(address(this));
        uint256 outputReserves = outputToken.balanceOf(address(this));

-        uint256 outputAmount = getOutputAmountBasedOnInput(inputAmount, inputReserves, outputReserves);
+        output = getOutputAmountBasedOnInput(inputAmount, inputReserves, outputReserves);

-        if (output < minOutputAmount) {
-            revert TSwapPool__OutputTooLow(outputAmount, minOutputAmount);
+        if (output < minOutputAmount) {
+            revert TSwapPool__OutputTooLow(outputAmount, minOutputAmount);
        }

-        _swap(inputToken, inputAmount, outputToken, outputAmount);
+        _swap(inputToken, inputAmount, output, outputAmount);

    }
```


## Informationals

### [I-1] `PoolFactory::PoolFactory__PoolDoesNotExist` is not used and should be removed

```diff
- error PoolFactory__PoolDoesNotExist(address tokenAddress);
```

### [I-2] Lacking zero address checks

```diff
    constructor(address wethToken) {
+       if(wethToken == address(0)) {
+           revert();
        }
        i_wethToken = wethToken;
    }
```

### [I-3] `PoolFactory::createPool` should use `.symbol()` instead of `.name()`

```diff
-    string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).name());
+     string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).symbol());
```

### [I-4] Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

<details><summary>4 Found Instances</summary>


- Found in src/PoolFactory.sol [Line: 35](src/PoolFactory.sol#L35)

    ```solidity
        event PoolCreated(address tokenAddress, address poolAddress);
    ```

- Found in src/TSwapPool.sol [Line: 43](src/TSwapPool.sol#L43)

    ```solidity
        event LiquidityAdded(address indexed liquidityProvider, uint256 wethDeposited, uint256 poolTokensDeposited);
    ```

- Found in src/TSwapPool.sol [Line: 44](src/TSwapPool.sol#L44)

    ```solidity
        event LiquidityRemoved(address indexed liquidityProvider, uint256 wethWithdrawn, uint256 poolTokensWithdrawn);
    ```

- Found in src/TSwapPool.sol [Line: 45](src/TSwapPool.sol#L45)

    ```solidity
        event Swap(address indexed swapper, IERC20 tokenIn, uint256 amountTokenIn, IERC20 tokenOut, uint256 amountTokenOut);
    ```

</details>

