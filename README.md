
# Rescript and Javascript library for Float

This library is used to interact with the Float smart contracts, which can also be accessed via the DApp: https://float.capital

Can view the contract addresses and other config here: https://github.com/Float-Capital/config
Can read the docs here: https://docs.float.capital/

## Getting started

All numeric parameters and return values are in BigNumber form (18 decimals) except for these params:
- marketIndex
- txOptions

### Rescript

To install run `yarn add @float-capital/rescript-client` or `npm install @float-capital/rescript-client` and then add the following to your bsconfig.json:
```
  "bs-dependencies": [
    "@float-capital/js-client",
    "@float-capital/config"
  ],
```

Here are some examples of how to use the library:

```rescript

// readonly chain initialization
let chain = Float.Chain.WithProvider.makeDefault(chainId)
// or
let chain = provider->Float.Chain.WithProvider.make

let marketIndex = 1

// readonly market initialization
let market = provider->Float.Market.WithProvider.make(marketIndex)
// or
let market = chain->Float.Market.makeUsingChain(marketIndex)

// readonly function call
market
->Float.Market.fundingRateMultiplier
->Promise.thenResolve(multiplier =>
  j`Funding rate multiplier for market $marketIndex:`
  ->Js.log2(multiplier)
)
->ignore

let isLong = true

// writable market side initialization
let side = wallet->Float.MarketSide.WithWallet.make(marketIndex, isLong)

// this is manual for now
let txOptions: Float.txOptions = {
  maxFeePerGas: 62, // gwei
  maxPriorityFeePerGas: 34, // gwei
  gasLimit: 1_000_000, // units
}

// write function call
side
->Float.MarketSide.mint(1->convertToBigNumber, txOptions)
->Promise.thenResolve(tx => tx.hash->Js.log)
->ignore
```

### Javascript

*This section needs some work*

```javascript
var Market = require("@float-capital/rescript-client/src/Float__Market.js");
var marketIndex = 1
var market = Market.WithProvider.make(provider, marketIndex);
Market.fundingRateMultiplier(market).then(function (multiplier) {
  console.log("Funding rate multiplier for market " + marketIndex + ":", multiplier);
});
```

## Full list of APIs

```rescript
Float.Chain.contracts // read
Float.Chain.updateSystemStateMulti // write

// read
Float.Market.contracts
Float.Market.unsettledPositions
Float.Market.stakedPositions
Float.Market.positions
Float.Market.fundingRateAprs
Float.Market.unconfirmedExposures
Float.Market.exposures
Float.Market.leverage
Float.Market.fundingRateMultiplier
Float.Market.syntheticTokenPrices

// write
Float.Market.updateSystemState
Float.Market.settleOutstandingActions
Float.Market.claimFloatCustom

// read
Float.MarketSide.syntheticToken
Float.MarketSide.name
Float.MarketSide.poolValue
Float.MarketSide.syntheticTokenPrice
Float.MarketSide.exposure
Float.MarketSide.unconfirmedExposure
Float.MarketSide.fundingRateApr
Float.MarketSide.positions
Float.MarketSide.stakedPositions
Float.MarketSide.unsettledPositions

// write
Float.MarketSide.mint
Float.MarketSide.mintAndStake
Float.MarketSide.stake
Float.MarketSide.unstake
Float.MarketSide.redeem
Float.MarketSide.shift
Float.MarketSide.shiftStake
```
