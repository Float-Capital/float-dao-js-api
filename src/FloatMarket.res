open FloatContracts
open Promise
open FloatUtil

// ====================================
// Convenience

let {div, fromInt, toNumber, tenToThe18} = module(FloatEthers.BigNumber)

// ====================================
// Type definitions

type bigNumbers = {
  long: FloatEthers.BigNumber.t,
  short: FloatEthers.BigNumber.t,
}

type longshortfloats = {
  long: float,
  short: float,
}

type longshortpositions = {
  long: FloatMarketSide.positions,
  short: FloatMarketSide.positions,
}

type contracts = {
  longToken: FloatConfig.erc20,
  shortToken: FloatConfig.erc20,
  yieldManager: FloatConfig.contract,
  // TODO add paymentToken but wait for the change in FloatConfig first
  // TODO add oracleManager but wait for the change in FloatConfig first
}

type withProvider = {provider: FloatEthers.providerType, marketIndex: int}
type withWallet = {wallet: FloatEthers.walletType, marketIndex: int}

type withProviderOrWallet =
  | P(withProvider)
  | W(withWallet)

let wrapSideP: withProvider => withProviderOrWallet = side => P(side)
let wrapSideW: withWallet => withProviderOrWallet = side => W(side)

// ====================================
// Constructors

module WithProvider = {
  type t = withProvider
  let make = (p, marketIndex) => {provider: p, marketIndex: marketIndex}
  let makeWrap = (p, marketIndex) => make(p, marketIndex)->wrapSideP
  let makeWrapReverseCurry = (marketIndex, p) => make(p, marketIndex)->wrapSideP
}

module WithWallet = {
  type t = withWallet
  let make = (w, marketIndex) => {wallet: w, marketIndex: marketIndex}
  let makeWrap = (w, marketIndex) => make(w, marketIndex)->wrapSideW
}

// ====================================
// Helper functions

let provider = (side: withProviderOrWallet) =>
  switch side {
  | P(s) => s.provider
  | W(s) => s.wallet.provider
  }

let marketIndex = (side: withProviderOrWallet) =>
  switch side {
  | P(s) => s.marketIndex
  | W(s) => s.marketIndex
  }

let makeLongShortContract = (p: FloatEthers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
  LongShort.make(
    ~address=c.contracts.longShort.address->FloatEthers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let makeStakerContract = (p: FloatEthers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
  Staker.make(
    ~address=c.contracts.longShort.address->FloatEthers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let leverage = (
  p: FloatEthers.providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: FloatEthers.BigNumber.t,
): Promise.t<int> =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.marketLeverage_e18(~marketIndex)
  ->thenResolve(m => m->div(tenToThe18)->toNumber)

let longSide = FloatMarketSide.WithProvider.makeWrapReverseCurry(true)
let shortSide = FloatMarketSide.WithProvider.makeWrapReverseCurry(false)

let syntheticTokenPrices = (
  p: FloatEthers.providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: int,
) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.syntheticTokenPrice,
    shortSide(marketIndex, p)->FloatMarketSide.syntheticTokenPrice,
  ))->thenResolve(((priceLong, priceShort)): bigNumbers => {
    {
      long: priceLong,
      short: priceShort,
    }
  })

let exposures = (p: FloatEthers.providerType, c: FloatConfig.chainConfigShape, marketIndex: int) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.exposure,
    shortSide(marketIndex, p)->FloatMarketSide.exposure,
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let unconfirmedExposures = (
  p: FloatEthers.providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: int,
) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.unconfirmedExposure,
    shortSide(marketIndex, p)->FloatMarketSide.unconfirmedExposure,
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let fundingRateAprs = (
  p: FloatEthers.providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: int,
) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.fundingRateApr,
    shortSide(marketIndex, p)->FloatMarketSide.fundingRateApr,
  ))->thenResolve(((rateLong, rateShort)): longshortfloats => {
    {
      long: rateLong,
      short: rateShort,
    }
  })

let positions = (
  p: FloatEthers.providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: int,
  address: FloatEthers.ethAddress,
) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.positions(address),
    shortSide(marketIndex, p)->FloatMarketSide.positions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let stakedPositions = (
  p: FloatEthers.providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: int,
  address: FloatEthers.ethAddress,
) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.stakedPositions(address),
    shortSide(marketIndex, p)->FloatMarketSide.stakedPositions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let unsettledPositions = (
  p: FloatEthers.providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: int,
  address: FloatEthers.ethAddress,
) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.unsettledPositions(address),
    shortSide(marketIndex, p)->FloatMarketSide.unsettledPositions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let claimFloatCustomFor = (
  w: FloatEthers.walletType,
  c: FloatConfig.chainConfigShape,
  marketIndexes: array<FloatEthers.BigNumber.t>,
  address: FloatEthers.ethAddress,
) =>
  w
  ->FloatEthers.wrapWallet
  ->makeStakerContract(c)
  ->Staker.claimFloatCustomFor(~marketIndexes, ~user=address)

let settleOutstandingActions = (
  w: FloatEthers.walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: FloatEthers.BigNumber.t,
  address: FloatEthers.ethAddress,
) =>
  w
  ->FloatEthers.wrapWallet
  ->makeLongShortContract(c)
  ->LongShort.executeOutstandingNextPriceSettlementsUser(~user=address, ~marketIndex)

let updateSystemState = (
  w: FloatEthers.walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: FloatEthers.BigNumber.t,
) => w->FloatEthers.wrapWallet->makeLongShortContract(c)->LongShort.updateSystemState(~marketIndex)

// ====================================
// Export functions

let contracts = (market: withProviderOrWallet) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->thenResolve(config => {
    longToken: config.markets[market->marketIndex].longToken,
    shortToken: config.markets[market->marketIndex].shortToken,
    yieldManager: config.markets[market->marketIndex].yieldManager,
  })

let leverage = (market: withProviderOrWallet) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    market->provider->leverage(config, market->marketIndex->FloatEthers.BigNumber.fromInt)
  )

let fundingRateMultiplier = (market: withProviderOrWallet) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    market
    ->provider
    ->FloatMarketSide.fundingRateMultiplier(
      config,
      market->marketIndex->FloatEthers.BigNumber.fromInt,
    )
  )

let syntheticTokenPrices = (market: withProviderOrWallet) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => market->provider->syntheticTokenPrices(config, market->marketIndex))

let exposures = (market: withProviderOrWallet) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => market->provider->exposures(config, market->marketIndex))

let unconfirmedExposures = (market: withProviderOrWallet) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => market->provider->unconfirmedExposures(config, market->marketIndex))

let fundingRateAprs = (market: withProviderOrWallet) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => market->provider->fundingRateAprs(config, market->marketIndex))

let positions = (market: withProviderOrWallet, ethAddress) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => market->provider->positions(config, market->marketIndex, ethAddress))

let stakedPositions = (market: withProviderOrWallet, ethAddress) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => market->provider->stakedPositions(config, market->marketIndex, ethAddress))

let unsettledPositions = (market: withProviderOrWallet, ethAddress) =>
  market
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => market->provider->unsettledPositions(config, market->marketIndex, ethAddress))

let side = (market: withProviderOrWallet, isLong) =>
  switch market {
  | P(m) => m.provider->FloatMarketSide.WithProvider.makeWrap(market->marketIndex, isLong)
  | W(m) => m.wallet->FloatMarketSide.WithWallet.makeWrap(market->marketIndex, isLong)
  }

let connect = (market: withProvider, wallet, isLong) =>
  wallet->FloatMarketSide.WithWallet.make(market.marketIndex, isLong)

let connectWrap = (market: withProviderOrWallet, wallet, isLong) =>
  wallet->FloatMarketSide.WithWallet.make(market->marketIndex, isLong)

let claimFloatCustomFor = (market: withWallet, ethAddress, txOptions) =>
  market.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(config =>
    market.wallet->claimFloatCustomFor(
      config,
      [market.marketIndex->FloatEthers.BigNumber.fromInt],
      ethAddress,
      txOptions,
    )
  )
let settleOutstandingActions = (market: withWallet, ethAddress, txOptions) =>
  market.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(config =>
    market.wallet->settleOutstandingActions(
      config,
      market.marketIndex->FloatEthers.BigNumber.fromInt,
      ethAddress,
      txOptions,
    )
  )
let updateSystemState = (market: withWallet, txOptions) =>
  market.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(config =>
    market.wallet->updateSystemState(
      config,
      market.marketIndex->FloatEthers.BigNumber.fromInt,
      txOptions,
    )
  )
