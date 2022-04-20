
TODO needs work

# Build
```
npm run build
```

# Watch

```
npm run watch
```

# What we want to JS client interop to look like

``` javascript
// NOTE 'get' prefix implies network calls (could also use 'fetch' instead)
// network call can be either to a blockchain or to the chain config repo

// NOTE 'unsettled' prefixed functions are those that include 
// next price actions in their calculation

float = floatDao.newClient(provider)

chains = float.getChains()
chain = chains[chainId]
chain = float.getChain(chainId) // or chain name, we will store this in config repo 

chain.longShortProxyAddress
chain.getLongShortmplentationAddress()
chain.fltAddress
chain.treasuryAddress

positions = chain.getPositions(address, side=Both, includeStake=False, includeNextPrice=False)
positions = chainWithSigner.getPositions(address=signer.address, side=Both, includeStake=False, includeNextPrice=False)
positions[marketIndex].long.paymentTokenAmount
positions[marketIndex].long.syntheticTokenAmount
positions[marketIndex].long.stake.paymentTokenAmount
positions[marketIndex].long.stake.syntheticTokenAmount

chainWithSigner = chain.connect(signer)
chainWithSigner.updateSystemState(marketIndexArray)
chainWithSigner.settleOutstandingActions(address=signer.address, marketIndexArray)

markets = float.getMarkets(chainId)
market = markets[marketIndex]
market = float.getMarket(chainId, marketIndex)
market = chain.getMarket(marketIndex)

market.tokenAddresses.paymentToken
market.tokenAddresses.longToken
market.tokenAddresses.shortToken

market.getExposure()
market.getUnsettledExposure()
market.getUnsettledExposure()
market.getLeverage()
market.getFundingRate()
market.getSyntheticTokenPrice(side)

positions = market.getPositions(address, side=Both, includeStake=False, includeNextPrice=False)
positions.long.paymentTokenAmount
// etc

marketWithSigner = chainWithSigner.getMarket(marketIndex)
marketWithSigner = market.connect(signer)
marketWithSigner.getPositions(address=signer.address, side=Both, includeStake=False, includeNextPrice=False)
marketWithSigner.mint(amount, side, alsoStake=Fasle)
marketWithSigner.redeem(amount, side, alsoStake=Fasle)
marketWithSigner.stake(amount, side)
marketWithSigner.unstake(amount, side)
marketWithSigner.shiftFrom(amount, originside, includeStake=False)
marketWithSigner.shiftStakeFrom(amount, originside)
marketWithSigner.claimFlt()
marketWithSigner.updateSystemState()
marketWithSigner.settleOutstandingActions(address=signer.address)

side = market.longSide
side.tokenAddress
side.getName // "long" or "short"

side.getPositions(address, includeStake=False, includeNextPrice=False)
side.getNextPricePositions(address)
side.getStakedPositions(address)
side.getSyntheticTokenPrice()

sideWithSigner = marketWithSigner.longSide
sideWithSigner = side.connect(signer)
sideWithSigner.mint(amount, alsoStake=False)
sideWithSigner.redeem(amount, alsoStake=False)
sideWithSigner.stake(amount)
sideWithSigner.unstake(amount)
sideWithSigner.shiftFrom(amount, originside, includeStake=False)
sideWithSigner.shiftStakeFrom(amount, originside)
sideWithSigner.getPositions(address=signer.address, includeStake=False, includeNextPrice=False)
sideWithSigner.getNextPricePositions(address=signer.address)
sideWithSigner.getStakedPositions(address=signer.address)

oracle = market.oracleManager
oracle.address
oracle.getPrice()

ym = market.yieldManager
ym.address
ym.providerAddress
```
