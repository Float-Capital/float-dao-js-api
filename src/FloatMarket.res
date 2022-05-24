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

type marketWithWallet = {
  getLeverage: unit => Promise.t<int>,
  getFundingRateMultiplier: unit => Promise.t<float>,
  getSyntheticTokenPrices: unit => Promise.t<bigNumbers>,
  getExposures: unit => Promise.t<bigNumbers>,
  getUnconfirmedExposures: unit => Promise.t<bigNumbers>,
  getFundingRateAprs: unit => Promise.t<longshortfloats>,
  getPositions: FloatEthers.ethAddress => Promise.t<longshortpositions>,
  getStakedPositions: FloatEthers.ethAddress => Promise.t<longshortpositions>,
  getUnsettledPositions: FloatEthers.ethAddress => Promise.t<longshortpositions>,
  claimFloatCustomFor: (FloatEthers.ethAddress, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  settleOutstandingActions: (
    FloatEthers.ethAddress,
    txOptions,
  ) => Promise.t<FloatEthers.txSubmitted>,
  updateSystemState: txOptions => Promise.t<FloatEthers.txSubmitted>,
  getSide: bool => FloatMarketSide.withWallet,
}

type marketWithProvider = {
  getLeverage: unit => Promise.t<int>,
  getFundingRateMultiplier: unit => Promise.t<float>,
  getSyntheticTokenPrices: unit => Promise.t<bigNumbers>,
  getExposures: unit => Promise.t<bigNumbers>,
  getUnconfirmedExposures: unit => Promise.t<bigNumbers>,
  getFundingRateAprs: unit => Promise.t<longshortfloats>,
  getPositions: FloatEthers.ethAddress => Promise.t<longshortpositions>,
  getStakedPositions: FloatEthers.ethAddress => Promise.t<longshortpositions>,
  getUnsettledPositions: FloatEthers.ethAddress => Promise.t<longshortpositions>,
  getSide: bool => FloatMarketSide.withProvider,
  connect: (FloatEthers.walletType, bool) => FloatMarketSide.withWallet,
}

let makeLongShortContract = (p: FloatEthers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
  LongShort.make(
    ~address=c.contracts.longShort.address->FloatEthers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let makeStakerContract = (p: FloatEthers.providerOrWallet, c: FloatConfig.chainConfigShape) =>
  Staker.make(~address=c.contracts.longShort.address->FloatEthers.Utils.getAddressUnsafe, ~providerOrWallet=p)

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

let syntheticTokenPrices = (p: FloatEthers.providerType, c: FloatConfig.chainConfigShape, marketIndex: int) =>
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

let unconfirmedExposures = (p: FloatEthers.providerType, c: FloatConfig.chainConfigShape, marketIndex: int) =>
  all2((
    longSide(marketIndex, p)->FloatMarketSide.unconfirmedExposure,
    shortSide(marketIndex, p)->FloatMarketSide.unconfirmedExposure,
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let fundingRateAprs = (p: FloatEthers.providerType, c: FloatConfig.chainConfigShape, marketIndex: int) =>
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
) => w->FloatEthers.wrapWallet->makeStakerContract(c)->Staker.claimFloatCustomFor(~marketIndexes, ~user=address)

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

let makeWithWallet = (w: FloatEthers.walletType, marketIndex: int): marketWithWallet => {
  {
    getLeverage: _ =>
      w->FloatEthers.wrapWallet->getChainConfig->then(c => leverage(w.provider, c, marketIndex->fromInt)),
    getFundingRateMultiplier: _ =>
      w
      ->FloatEthers.wrapWallet
      ->getChainConfig
      ->then(c =>
        FloatMarketSide.fundingRateMultiplier(w.provider, c, marketIndex->FloatEthers.BigNumber.fromInt)
      ),
    getSyntheticTokenPrices: _ =>
      w->FloatEthers.wrapWallet->getChainConfig->then(c => syntheticTokenPrices(w.provider, c, marketIndex)),
    getExposures: _ =>
      w->FloatEthers.wrapWallet->getChainConfig->then(c => exposures(w.provider, c, marketIndex)),
    getUnconfirmedExposures: _ =>
      w->FloatEthers.wrapWallet->getChainConfig->then(c => unconfirmedExposures(w.provider, c, marketIndex)),
    getFundingRateAprs: _ =>
      w->FloatEthers.wrapWallet->getChainConfig->then(c => fundingRateAprs(w.provider, c, marketIndex)),
    getPositions: ethAddress =>
      w->FloatEthers.wrapWallet->getChainConfig->then(c => positions(w.provider, c, marketIndex, ethAddress)),
    getStakedPositions: ethAddress =>
      w
      ->FloatEthers.wrapWallet
      ->getChainConfig
      ->then(c => stakedPositions(w.provider, c, marketIndex, ethAddress)),
    getUnsettledPositions: ethAddress =>
      w
      ->FloatEthers.wrapWallet
      ->getChainConfig
      ->then(c => unsettledPositions(w.provider, c, marketIndex, ethAddress)),
    claimFloatCustomFor: (ethAddress, txOptions) =>
      w
      ->FloatEthers.wrapWallet
      ->getChainConfig
      ->then(c =>
        claimFloatCustomFor(w, c, [marketIndex->FloatEthers.BigNumber.fromInt], ethAddress, txOptions)
      ),
    settleOutstandingActions: (ethAddress, txOptions) =>
      w
      ->FloatEthers.wrapWallet
      ->getChainConfig
      ->then(c =>
        settleOutstandingActions(w, c, marketIndex->FloatEthers.BigNumber.fromInt, ethAddress, txOptions)
      ),
    updateSystemState: txOptions =>
      w
      ->FloatEthers.wrapWallet
      ->getChainConfig
      ->then(c => updateSystemState(w, c, marketIndex->FloatEthers.BigNumber.fromInt, txOptions)),
    getSide: FloatMarketSide.WithWallet.make(w, marketIndex),
  }
}

let makeWithProvider = (p: FloatEthers.providerType, marketIndex: int): marketWithProvider => {
  {
    getLeverage: _ =>
      p->FloatEthers.wrapProvider->getChainConfig->then(c => leverage(p, c, marketIndex->FloatEthers.BigNumber.fromInt)),
    getFundingRateMultiplier: _ =>
      p
      ->FloatEthers.wrapProvider
      ->getChainConfig
      ->then(c => FloatMarketSide.fundingRateMultiplier(p, c, marketIndex->FloatEthers.BigNumber.fromInt)),
    getSyntheticTokenPrices: _ =>
      p->FloatEthers.wrapProvider->getChainConfig->then(c => syntheticTokenPrices(p, c, marketIndex)),
    getExposures: _ => p->FloatEthers.wrapProvider->getChainConfig->then(c => exposures(p, c, marketIndex)),
    getUnconfirmedExposures: _ =>
      p->FloatEthers.wrapProvider->getChainConfig->then(c => unconfirmedExposures(p, c, marketIndex)),
    getFundingRateAprs: _ =>
      p->FloatEthers.wrapProvider->getChainConfig->then(c => fundingRateAprs(p, c, marketIndex)),
    getPositions: ethAddress =>
      p->FloatEthers.wrapProvider->getChainConfig->then(c => positions(p, c, marketIndex, ethAddress)),
    getStakedPositions: ethAddress =>
      p->FloatEthers.wrapProvider->getChainConfig->then(c => stakedPositions(p, c, marketIndex, ethAddress)),
    getUnsettledPositions: ethAddress =>
      p->FloatEthers.wrapProvider->getChainConfig->then(c => unsettledPositions(p, c, marketIndex, ethAddress)),
    getSide: isLong => FloatMarketSide.WithProvider.make(p, marketIndex, isLong),
    connect: (w, isLong) => FloatMarketSide.WithWallet.make(w, marketIndex, isLong),
  }
}

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
