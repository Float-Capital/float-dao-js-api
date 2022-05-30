open Float__Contracts
open Promise
open Float__Util
open Float__Market__shared

// ====================================
// Convenience

let {div, fromInt, toNumber, tenToThe18} = module(Float__Ethers.BigNumber)

// ====================================
// Type definitions

type bigNumbers = {
  long: Float__Ethers.BigNumber.t,
  short: Float__Ethers.BigNumber.t,
}

type longshortfloats = {
  long: float,
  short: float,
}

type longshortpositions = {
  long: Float__MarketSide.positions,
  short: Float__MarketSide.positions,
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

  // the unwrapped version is not the default but may be useful for rescript consumers
  //   that don't want to have to do a switch statement
  let makeUnwrapped = (provider, marketIndex) => {provider: provider, marketIndex: marketIndex}
  let make = (provider, marketIndex) => provider->makeUnwrapped(marketIndex)->wrapMarketP

  // this is just a convenience file that is used inside this repo,
  //   but it may be useful to consumers so why not leave it public
  let makeReverseCurry = (marketIndex, provider) => provider->makeUnwrapped(marketIndex)->wrapMarketP

  // default provider can also be used
  let makeDefault = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->make
  let makeDefaultUnwrapped = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->makeUnwrapped
}

module WithWallet = {
  type t = withWallet
  let makeUnwrapped = (w, marketIndex) => {wallet: w, marketIndex: marketIndex}
  let make = (w, marketIndex) => makeUnwrapped(w, marketIndex)->wrapMarketW
}

let makeUsingChain = (chain, marketIndex) =>
  switch chain {
  | Float__Chain.P(c) => c.provider->WithProvider.make(marketIndex)
  | Float__Chain.W(c) => c.wallet->WithWallet.make(marketIndex)
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

%%private(let longSide = Float__MarketSide.WithProvider.makeReverseCurry(true))
%%private(let shortSide = Float__MarketSide.WithProvider.makeReverseCurry(false))

let makeLongShortContract = (p: Float__Ethers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Float__Ethers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let makeStakerContract = (p: Float__Ethers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
  Staker.make(
    ~address=c.contracts.longShort.address->Float__Ethers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let leverage = (provider, config, marketIndex): Promise.t<int> =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.marketLeverage_e18(~marketIndex)
  ->thenResolve(m => m->div(tenToThe18)->toNumber)

let syntheticTokenPrices = (provider, marketIndex) =>
  all2((
    longSide(marketIndex, provider)->Float__MarketSide.syntheticTokenPrice,
    shortSide(marketIndex, provider)->Float__MarketSide.syntheticTokenPrice,
  ))->thenResolve(((priceLong, priceShort)): bigNumbers => {
    {
      long: priceLong,
      short: priceShort,
    }
  })

let exposures = (provider, marketIndex: int) =>
  all2((
    longSide(marketIndex, provider)->Float__MarketSide.exposure,
    shortSide(marketIndex, provider)->Float__MarketSide.exposure,
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let unconfirmedExposures = (provider, marketIndex) =>
  all2((
    longSide(marketIndex, provider)->Float__MarketSide.unconfirmedExposure,
    shortSide(marketIndex, provider)->Float__MarketSide.unconfirmedExposure,
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let fundingRateAprs = (provider, marketIndex) =>
  all2((
    longSide(marketIndex, provider)->Float__MarketSide.fundingRateApr,
    shortSide(marketIndex, provider)->Float__MarketSide.fundingRateApr,
  ))->thenResolve(((rateLong, rateShort)): longshortfloats => {
    {
      long: rateLong,
      short: rateShort,
    }
  })

let positions = (provider, marketIndex, address) =>
  all2((
    longSide(marketIndex, provider)->Float__MarketSide.positions(address),
    shortSide(marketIndex, provider)->Float__MarketSide.positions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let stakedPositions = (provider, marketIndex, address) =>
  all2((
    longSide(marketIndex, provider)->Float__MarketSide.stakedPositions(address),
    shortSide(marketIndex, provider)->Float__MarketSide.stakedPositions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let unsettledPositions = (provider, marketIndex, address) =>
  all2((
    longSide(marketIndex, provider)->Float__MarketSide.unsettledPositions(address),
    shortSide(marketIndex, provider)->Float__MarketSide.unsettledPositions(address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let claimFloatCustomFor = (wallet, config, marketIndexes, address) =>
  wallet
  ->Float__Ethers.wrapWallet
  ->makeStakerContract(config)
  ->Staker.claimFloatCustomFor(~marketIndexes, ~user=address)

let settleOutstandingActions = (wallet, config, marketIndex, address) =>
  wallet
  ->Float__Ethers.wrapWallet
  ->makeLongShortContract(config)
  ->LongShort.executeOutstandingNextPriceSettlementsUser(~user=address, ~marketIndex)

let updateSystemState = (wallet, config, marketIndex) =>
  wallet
  ->Float__Ethers.wrapWallet
  ->makeLongShortContract(config)
  ->LongShort.updateSystemState(~marketIndex)

// ====================================
// Export functions

let contracts = (market: withProviderOrWallet) =>
  market
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->thenResolve(config => {
    longToken: config.markets[market->marketIndex].longToken,
    shortToken: config.markets[market->marketIndex].shortToken,
    yieldManager: config.markets[market->marketIndex].yieldManager,
  })

let leverage = (market: withProviderOrWallet) =>
  market
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config =>
    market->provider->leverage(config, market->marketIndex->Float__Ethers.BigNumber.fromInt)
  )

let fundingRateMultiplier = (market: withProviderOrWallet) =>
  market
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config =>
    market
    ->provider
    ->Float__MarketSide.fundingRateMultiplier(
      config,
      market->marketIndex->Float__Ethers.BigNumber.fromInt,
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
  ->Float__Ethers.wrapWallet
  ->getChainConfig
  ->then(config => {
    let address = switch ethAddress {
    | Some(value) => value
    | None => market.wallet.address
    }
    market.wallet->claimFloatCustomFor(
      config,
      [market.marketIndex->Float__Ethers.BigNumber.fromInt],
      address->Float__Ethers.Utils.getAddressUnsafe,
      txOptions,
    )
  })
let settleOutstandingActions = (market: withWallet, ~ethAddress=?, txOptions) =>
  market.wallet
  ->Float__Ethers.wrapWallet
  ->getChainConfig
  ->then(config => {
    let address = switch ethAddress {
    | Some(value) => value
    | None => market.wallet.address
    }
    market.wallet->settleOutstandingActions(
      config,
      market.marketIndex->Float__Ethers.BigNumber.fromInt,
      address->Float__Ethers.Utils.getAddressUnsafe,
      txOptions,
    )
  })
let updateSystemState = (market: withWallet, txOptions) =>
  market.wallet
  ->Float__Ethers.wrapWallet
  ->getChainConfig
  ->then(config =>
    market.wallet->updateSystemState(
      config,
      market.marketIndex->Float__Ethers.BigNumber.fromInt,
      txOptions,
    )
  )
