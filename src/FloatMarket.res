open FloatContracts
open Promise
open FloatUtil
open FloatMarketTypes

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

// ====================================
// Constructors

module WithProvider = {
  type t = withProvider
  // TODO change the following around so that wrap is default
  let make = (provider, marketIndex) => {provider: provider, marketIndex: marketIndex}
  let makeWrap = (provider, marketIndex) => provider->make(marketIndex)->wrapMarketP
  let makeWrapReverseCurry = (marketIndex, provider) => provider->make(marketIndex)->wrapMarketP
}

module WithWallet = {
  type t = withWallet
  let make = (w, marketIndex) => {wallet: w, marketIndex: marketIndex}
  let makeWrap = (w, marketIndex) => make(w, marketIndex)->wrapMarketW
}

let makeUsingChain = (chain, marketIndex) =>
  switch chain {
  | FloatChain.P(c) => c.provider->WithProvider.makeWrap(marketIndex)
  | FloatChain.W(c) => c.wallet->WithWallet.makeWrap(marketIndex)
  }

// ====================================
// Helper functions

%%private(
  let provider = (side: withProviderOrWallet) =>
    switch side {
    | P(s) => s.provider
    | W(s) => s.wallet.provider
    }
)

%%private(
  let marketIndex = (side: withProviderOrWallet) =>
    switch side {
    | P(s) => s.marketIndex
    | W(s) => s.marketIndex
    }
)

%%private(let longSide = FloatMarketSide.WithProvider.makeWrapReverseCurry(true))
%%private(let shortSide = FloatMarketSide.WithProvider.makeWrapReverseCurry(false))

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

let leverage = (provider, config, marketIndex): Promise.t<int> =>
  provider
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.marketLeverage_e18(~marketIndex)
  ->thenResolve(m => m->div(tenToThe18)->toNumber)

let syntheticTokenPrices = (provider, marketIndex) =>
  all2((
    longSide(marketIndex, provider)->FloatMarketSide.syntheticTokenPrice,
    shortSide(marketIndex, provider)->FloatMarketSide.syntheticTokenPrice,
  ))->thenResolve(((priceLong, priceShort)): bigNumbers => {
    {
      long: priceLong,
      short: priceShort,
    }
  })

let exposures = (provider, marketIndex: int) =>
  all2((
    longSide(marketIndex, provider)->FloatMarketSide.exposure,
    shortSide(marketIndex, provider)->FloatMarketSide.exposure,
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let unconfirmedExposures = (provider, marketIndex) =>
  all2((
    longSide(marketIndex, provider)->FloatMarketSide.unconfirmedExposure,
    shortSide(marketIndex, provider)->FloatMarketSide.unconfirmedExposure,
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let fundingRateAprs = (provider, marketIndex) =>
  all2((
    longSide(marketIndex, provider)->FloatMarketSide.fundingRateApr,
    shortSide(marketIndex, provider)->FloatMarketSide.fundingRateApr,
  ))->thenResolve(((rateLong, rateShort)): longshortfloats => {
    {
      long: rateLong,
      short: rateShort,
    }
  })

let positions = (provider, marketIndex, address) =>
  all2((
    longSide(marketIndex, provider)->FloatMarketSide.positions(address),
    shortSide(marketIndex, provider)->FloatMarketSide.positions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let stakedPositions = (provider, marketIndex, address) =>
  all2((
    longSide(marketIndex, provider)->FloatMarketSide.stakedPositions(address),
    shortSide(marketIndex, provider)->FloatMarketSide.stakedPositions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let unsettledPositions = (provider, marketIndex, address) =>
  all2((
    longSide(marketIndex, provider)->FloatMarketSide.unsettledPositions(address),
    shortSide(marketIndex, provider)->FloatMarketSide.unsettledPositions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let claimFloatCustomFor = (wallet, config, marketIndexes, address) =>
  wallet
  ->FloatEthers.wrapWallet
  ->makeStakerContract(config)
  ->Staker.claimFloatCustomFor(~marketIndexes, ~user=address)

let settleOutstandingActions = (wallet, config, marketIndex, address) =>
  wallet
  ->FloatEthers.wrapWallet
  ->makeLongShortContract(config)
  ->LongShort.executeOutstandingNextPriceSettlementsUser(~user=address, ~marketIndex)

let updateSystemState = (wallet, config, marketIndex) =>
  wallet
  ->FloatEthers.wrapWallet
  ->makeLongShortContract(config)
  ->LongShort.updateSystemState(~marketIndex)

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
  market->provider->syntheticTokenPrices(market->marketIndex)

let exposures = (market: withProviderOrWallet) => market->provider->exposures(market->marketIndex)

let unconfirmedExposures = (market: withProviderOrWallet) =>
  market->provider->unconfirmedExposures(market->marketIndex)

let fundingRateAprs = (market: withProviderOrWallet) =>
  market->provider->fundingRateAprs(market->marketIndex)

let positions = (market: withProviderOrWallet, ethAddress) =>
  market->provider->positions(market->marketIndex, ethAddress)

let stakedPositions = (market: withProviderOrWallet, ethAddress) =>
  market->provider->stakedPositions(market->marketIndex, ethAddress)

let unsettledPositions = (market: withProviderOrWallet, ethAddress) =>
  market->provider->unsettledPositions(market->marketIndex, ethAddress)

let claimFloatCustom = (market: withWallet, ~ethAddress=?, txOptions) =>
  market.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(config => {
    let address = switch ethAddress {
    | Some(value) => value
    | None => market.wallet.address
    }
    market.wallet->claimFloatCustomFor(
      config,
      [market.marketIndex->FloatEthers.BigNumber.fromInt],
      address->FloatEthers.Utils.getAddressUnsafe,
      txOptions,
    )
  })
let settleOutstandingActions = (market: withWallet, ~ethAddress=?, txOptions) =>
  market.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(config => {
    let address = switch ethAddress {
    | Some(value) => value
    | None => market.wallet.address
    }
    market.wallet->settleOutstandingActions(
      config,
      market.marketIndex->FloatEthers.BigNumber.fromInt,
      address->FloatEthers.Utils.getAddressUnsafe,
      txOptions,
    )
  })
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
