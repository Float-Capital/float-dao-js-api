open Contracts
open Ethers
open Promise
open Config
open FloatConfig

let {fromInt} = module(Ethers.BigNumber)

type bigNumbers = {
  long: Ethers.BigNumber.t,
  short: Ethers.BigNumber.t,
}

type floats = {
  long: float,
  short: float,
}

type positions = {
  long: MarketSide.positions,
  short: MarketSide.positions,
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
  getLeverage: unit => Promise.t<BigNumber.t>, // TODO change to int
  getFundingRateMultiplier: unit => Promise.t<float>,
  getSyntheticTokenPrices: unit => Promise.t<bigNumbers>,
  getExposures: unit => Promise.t<bigNumbers>,
  getUnconfirmedExposures: unit => Promise.t<bigNumbers>,
  getFundingRateAprs: unit => Promise.t<floats>,
  getPositions: ethAddress => Promise.t<positions>,
  getStakedPositions: ethAddress => Promise.t<positions>,
  getUnsettledPositions: ethAddress => Promise.t<positions>,
  claimFloatCustomFor: (ethAddress, txOptions) => Promise.t<Ethers.txSubmitted>,
  settleOutstandingActions: (ethAddress, txOptions) => Promise.t<Ethers.txSubmitted>,
  updateSystemState: txOptions => Promise.t<Ethers.txSubmitted>,
  getSide: bool => MarketSide.marketSideWithWallet,
}

type marketWithProvider = {
  contracts: Promise.t<contracts>,
  getLeverage: unit => Promise.t<BigNumber.t>,
  getFundingRateMultiplier: unit => Promise.t<float>,
  getSyntheticTokenPrices: unit => Promise.t<bigNumbers>,
  getExposures: unit => Promise.t<bigNumbers>,
  getUnconfirmedExposures: unit => Promise.t<bigNumbers>,
  getFundingRateAprs: unit => Promise.t<floats>,
  getPositions: ethAddress => Promise.t<positions>,
  getStakedPositions: ethAddress => Promise.t<positions>,
  getUnsettledPositions: ethAddress => Promise.t<positions>,
  getSide: bool => MarketSide.marketSideWithProvider,
  connect: walletType => marketWithWallet,
}

let makeLongShortContract = (p: providerOrWallet, c: chainConfigShape) =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let makeStakerContract = (p: providerOrWallet, c: chainConfigShape) =>
  Staker.make(~address=c.contracts.longShort.address->Utils.getAddressUnsafe, ~providerOrWallet=p)

let leverage = (p: providerType, c: chainConfigShape, marketIndex: BigNumber.t): Promise.t<
  BigNumber.t,
> => p->wrapProvider->makeLongShortContract(c)->LongShort.marketLeverage_e18(~marketIndex)

let syntheticTokenPrices = (p: providerType, c: chainConfigShape, marketIndex: BigNumber.t) =>
  all2((
    MarketSide.syntheticTokenPrice(p, c, marketIndex, true),
    MarketSide.syntheticTokenPrice(p, c, marketIndex, false),
  ))->thenResolve(((priceLong, priceShort)): bigNumbers => {
    {
      long: priceLong,
      short: priceShort,
    }
  })

let exposures = (p: providerType, c: chainConfigShape, marketIndex: BigNumber.t) =>
  all2((
    MarketSide.exposure(p, c, marketIndex, true),
    MarketSide.exposure(p, c, marketIndex, false),
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let unconfirmedExposures = (p: providerType, c: chainConfigShape, marketIndex: BigNumber.t) =>
  all2((
    MarketSide.unconfirmedExposure(p, c, marketIndex, true),
    MarketSide.unconfirmedExposure(p, c, marketIndex, false),
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let fundingRateAprs = (p: providerType, c: chainConfigShape, marketIndex: BigNumber.t) =>
  all2((
    MarketSide.fundingRateApr(p, c, marketIndex, true),
    MarketSide.fundingRateApr(p, c, marketIndex, false),
  ))->thenResolve(((rateLong, rateShort)): floats => {
    {
      long: rateLong,
      short: rateShort,
    }
  })

let positions = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  all2((
    MarketSide.positions(p, c, marketIndex, true, address),
    MarketSide.positions(p, c, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let stakedPositions = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  all2((
    MarketSide.stakedPositions(p, c, marketIndex, true, address),
    MarketSide.stakedPositions(p, c, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let unsettledPositions = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  all2((
    MarketSide.unsettledPositions(p, c, marketIndex, true, address),
    MarketSide.unsettledPositions(p, c, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let claimFloatCustomFor = (
  w: walletType,
  c: chainConfigShape,
  marketIndexes: array<BigNumber.t>,
  address: ethAddress,
) => w->wrapWallet->makeStakerContract(c)->Staker.claimFloatCustomFor(~marketIndexes, ~user=address)

let settleOutstandingActions = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  address: ethAddress,
) =>
  w
  ->wrapWallet
  ->makeLongShortContract(c)
  ->LongShort.executeOutstandingNextPriceSettlementsUser(~user=address, ~marketIndex)

let updateSystemState = (w: walletType, c: chainConfigShape, marketIndex: BigNumber.t) =>
  w->wrapWallet->makeLongShortContract(c)->LongShort.updateSystemState(~marketIndex)

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
      ->then(c => MarketSide.fundingRateMultiplier(w.provider, c, marketIndex->BigNumber.fromInt)),
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
    getSide: MarketSide.makeWithWallet(w, marketIndex),
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
      ->then(c => MarketSide.fundingRateMultiplier(p, c, marketIndex->BigNumber.fromInt)),
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
    getSide: isLong => MarketSide.makeWithProvider(p, marketIndex, isLong),
    connect: w => makeWithWallet(w, marketIndex),
  }
}
