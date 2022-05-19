open FloatContracts
open FloatEthers
open Promise
open FloatUtil

let {div, fromInt, toNumber, tenToThe18} = module(FloatEthers.BigNumber)

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

type marketWithWallet = {
  contracts: Promise.t<contracts>,
  getLeverage: unit => Promise.t<int>,
  getFundingRateMultiplier: unit => Promise.t<float>,
  getSyntheticTokenPrices: unit => Promise.t<bigNumbers>,
  getExposures: unit => Promise.t<bigNumbers>,
  getUnconfirmedExposures: unit => Promise.t<bigNumbers>,
  getFundingRateAprs: unit => Promise.t<longshortfloats>,
  getPositions: ethAddress => Promise.t<longshortpositions>,
  getStakedPositions: ethAddress => Promise.t<longshortpositions>,
  getUnsettledPositions: ethAddress => Promise.t<longshortpositions>,
  claimFloatCustomFor: (ethAddress, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  settleOutstandingActions: (ethAddress, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  updateSystemState: txOptions => Promise.t<FloatEthers.txSubmitted>,
  getSide: bool => FloatMarketSide.marketSideWithWallet,
}

type marketWithProvider = {
  contracts: Promise.t<contracts>,
  getLeverage: unit => Promise.t<int>,
  getFundingRateMultiplier: unit => Promise.t<float>,
  getSyntheticTokenPrices: unit => Promise.t<bigNumbers>,
  getExposures: unit => Promise.t<bigNumbers>,
  getUnconfirmedExposures: unit => Promise.t<bigNumbers>,
  getFundingRateAprs: unit => Promise.t<longshortfloats>,
  getPositions: ethAddress => Promise.t<longshortpositions>,
  getStakedPositions: ethAddress => Promise.t<longshortpositions>,
  getUnsettledPositions: ethAddress => Promise.t<longshortpositions>,
  getSide: bool => FloatMarketSide.marketSideWithProvider,
  connect: walletType => marketWithWallet,
}

let makeLongShortContract = (p: providerOrWallet, c: FloatConfig.chainConfigShape) =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let makeStakerContract = (p: providerOrWallet, c: FloatConfig.chainConfigShape) =>
  Staker.make(~address=c.contracts.longShort.address->Utils.getAddressUnsafe, ~providerOrWallet=p)

let leverage = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
): Promise.t<int> =>
  p
  ->wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.marketLeverage_e18(~marketIndex)
  ->thenResolve(m => m->div(tenToThe18)->toNumber)

let syntheticTokenPrices = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
) =>
  all2((
    FloatMarketSide.syntheticTokenPrice(p, c, marketIndex, true),
    FloatMarketSide.syntheticTokenPrice(p, c, marketIndex, false),
  ))->thenResolve(((priceLong, priceShort)): bigNumbers => {
    {
      long: priceLong,
      short: priceShort,
    }
  })

let exposures = (p: providerType, c: FloatConfig.chainConfigShape, marketIndex: BigNumber.t) =>
  all2((
    FloatMarketSide.exposure(p, c, marketIndex, true),
    FloatMarketSide.exposure(p, c, marketIndex, false),
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let unconfirmedExposures = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
) =>
  all2((
    FloatMarketSide.unconfirmedExposure(p, c, marketIndex, true),
    FloatMarketSide.unconfirmedExposure(p, c, marketIndex, false),
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let fundingRateAprs = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
) =>
  all2((
    FloatMarketSide.fundingRateApr(p, c, marketIndex, true),
    FloatMarketSide.fundingRateApr(p, c, marketIndex, false),
  ))->thenResolve(((rateLong, rateShort)): longshortfloats => {
    {
      long: rateLong,
      short: rateShort,
    }
  })

let positions = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  all2((
    FloatMarketSide.positions(p, c, marketIndex, true, address),
    FloatMarketSide.positions(p, c, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let stakedPositions = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  all2((
    FloatMarketSide.stakedPositions(p, c, marketIndex, true, address),
    FloatMarketSide.stakedPositions(p, c, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let unsettledPositions = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  all2((
    FloatMarketSide.unsettledPositions(p, c, marketIndex, true, address),
    FloatMarketSide.unsettledPositions(p, c, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let claimFloatCustomFor = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndexes: array<BigNumber.t>,
  address: ethAddress,
) => w->wrapWallet->makeStakerContract(c)->Staker.claimFloatCustomFor(~marketIndexes, ~user=address)

let settleOutstandingActions = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  w
  ->wrapWallet
  ->makeLongShortContract(c)
  ->LongShort.executeOutstandingNextPriceSettlementsUser(~user=address, ~marketIndex)

let updateSystemState = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: BigNumber.t,
) => w->wrapWallet->makeLongShortContract(c)->LongShort.updateSystemState(~marketIndex)

let makeWithWallet = (w: walletType, marketIndex: int): marketWithWallet => {
  {
    contracts: w
    ->wrapWallet
    ->getChainConfig
    ->thenResolve(c => {
      longToken: c.markets[marketIndex].longToken,
      shortToken: c.markets[marketIndex].shortToken,
      yieldManager: c.markets[marketIndex].yieldManager,
    }),
    getLeverage: _ =>
      w->wrapWallet->getChainConfig->then(c => leverage(w.provider, c, marketIndex->fromInt)),
    getFundingRateMultiplier: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        FloatMarketSide.fundingRateMultiplier(w.provider, c, marketIndex->BigNumber.fromInt)
      ),
    getSyntheticTokenPrices: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => syntheticTokenPrices(w.provider, c, marketIndex->BigNumber.fromInt)),
    getExposures: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => exposures(w.provider, c, marketIndex->BigNumber.fromInt)),
    getUnconfirmedExposures: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => unconfirmedExposures(w.provider, c, marketIndex->BigNumber.fromInt)),
    getFundingRateAprs: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => fundingRateAprs(w.provider, c, marketIndex->BigNumber.fromInt)),
    getPositions: ethAddress =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => positions(w.provider, c, marketIndex->BigNumber.fromInt, ethAddress)),
    getStakedPositions: ethAddress =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => stakedPositions(w.provider, c, marketIndex->BigNumber.fromInt, ethAddress)),
    getUnsettledPositions: ethAddress =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => unsettledPositions(w.provider, c, marketIndex->BigNumber.fromInt, ethAddress)),
    claimFloatCustomFor: (ethAddress, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        claimFloatCustomFor(w, c, [marketIndex->BigNumber.fromInt], ethAddress, txOptions)
      ),
    settleOutstandingActions: (ethAddress, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        settleOutstandingActions(w, c, marketIndex->BigNumber.fromInt, ethAddress, txOptions)
      ),
    updateSystemState: txOptions =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => updateSystemState(w, c, marketIndex->BigNumber.fromInt, txOptions)),
    getSide: FloatMarketSide.makeWithWallet(w, marketIndex),
  }
}

let makeWithProvider = (p: providerType, marketIndex: int): marketWithProvider => {
  {
    contracts: p
    ->wrapProvider
    ->getChainConfig
    ->thenResolve(c => {
      longToken: c.markets[marketIndex].longToken,
      shortToken: c.markets[marketIndex].shortToken,
      yieldManager: c.markets[marketIndex].yieldManager,
    }),
    getLeverage: _ =>
      p->wrapProvider->getChainConfig->then(c => leverage(p, c, marketIndex->BigNumber.fromInt)),
    getFundingRateMultiplier: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => FloatMarketSide.fundingRateMultiplier(p, c, marketIndex->BigNumber.fromInt)),
    getSyntheticTokenPrices: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => syntheticTokenPrices(p, c, marketIndex->BigNumber.fromInt)),
    getExposures: _ =>
      p->wrapProvider->getChainConfig->then(c => exposures(p, c, marketIndex->BigNumber.fromInt)),
    getUnconfirmedExposures: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => unconfirmedExposures(p, c, marketIndex->BigNumber.fromInt)),
    getFundingRateAprs: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => fundingRateAprs(p, c, marketIndex->BigNumber.fromInt)),
    getPositions: ethAddress =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => positions(p, c, marketIndex->BigNumber.fromInt, ethAddress)),
    getStakedPositions: ethAddress =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => stakedPositions(p, c, marketIndex->BigNumber.fromInt, ethAddress)),
    getUnsettledPositions: ethAddress =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => unsettledPositions(p, c, marketIndex->BigNumber.fromInt, ethAddress)),
    getSide: isLong => FloatMarketSide.makeWithProvider(p, marketIndex, isLong),
    connect: w => makeWithWallet(w, marketIndex),
  }
}
