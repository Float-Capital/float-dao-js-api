open Contracts
open Ethers
open ConfigMain
open Promise

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

type marketWithWallet = {
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

let makeLongShortContract = (p: providerOrWallet) =>
  LongShort.make(
    ~address=polygonConfig.longShortContractAddress->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let makeStakerContract = (p: providerOrWallet) =>
  Staker.make(
    ~address=polygonConfig.stakerContractAddress->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let leverage = (p: providerType, marketIndex: BigNumber.t): Promise.t<BigNumber.t> =>
  p->wrapProvider->makeLongShortContract->LongShort.marketLeverage_e18(~marketIndex)

let syntheticTokenPrices = (p: providerType, marketIndex: BigNumber.t) =>
  all2((
    MarketSide.syntheticTokenPrice(p, marketIndex, true),
    MarketSide.syntheticTokenPrice(p, marketIndex, false),
  ))->thenResolve(((priceLong, priceShort)): bigNumbers => {
    {
      long: priceLong,
      short: priceShort,
    }
  })

let exposures = (p: providerType, marketIndex: BigNumber.t) =>
  all2((
    MarketSide.exposure(p, marketIndex, true),
    MarketSide.exposure(p, marketIndex, false),
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let unconfirmedExposures = (p: providerType, marketIndex: BigNumber.t) =>
  all2((
    MarketSide.unconfirmedExposure(p, marketIndex, true),
    MarketSide.unconfirmedExposure(p, marketIndex, false),
  ))->thenResolve(((exposureLong, exposureShort)): bigNumbers => {
    {
      long: exposureLong,
      short: exposureShort,
    }
  })

let fundingRateAprs = (p: providerType, marketIndex: BigNumber.t) =>
    all2((
      MarketSide.fundingRateApr(p, marketIndex, true),
      MarketSide.fundingRateApr(p, marketIndex, false),
    ))->thenResolve(((rateLong, rateShort)): floats => {
      {
        long: rateLong,
        short: rateShort,
      }
    })

let positions = (p: providerType, marketIndex: BigNumber.t, address: ethAddress) =>
  all2((
    MarketSide.positions(p, marketIndex, true, address),
    MarketSide.positions(p, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let stakedPositions = (p: providerType, marketIndex: BigNumber.t, address: ethAddress) =>
  all2((
    MarketSide.stakedPositions(p, marketIndex, true, address),
    MarketSide.stakedPositions(p, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let unsettledPositions = (p: providerType, marketIndex: BigNumber.t, address: ethAddress) =>
  all2((
    MarketSide.unsettledPositions(p, marketIndex, true, address),
    MarketSide.unsettledPositions(p, marketIndex, false, address),
  ))->thenResolve(((positionLong, positionShort)) => {
    long: positionLong,
    short: positionShort,
  })

let claimFloatCustomFor = (w: walletType, marketIndexes: array<BigNumber.t>, address: ethAddress) =>
  w->wrapWallet->makeStakerContract->Staker.claimFloatCustomFor(~marketIndexes, ~user=address)

let settleOutstandingActions = (w: walletType, marketIndex: BigNumber.t, address: ethAddress) =>
    w->wrapWallet->makeLongShortContract->LongShort.executeOutstandingNextPriceSettlementsUser(~user=address, ~marketIndex)

let updateSystemState = (w: walletType, marketIndex: BigNumber.t) =>
    w->wrapWallet->makeLongShortContract->LongShort.updateSystemState(~marketIndex)

let makeWithWallet = (w: walletType, marketIndex: BigNumber.t): marketWithWallet => {
  {
    getLeverage: _ => leverage(w.provider, marketIndex),
    getFundingRateMultiplier: _ => MarketSide.fundingRateMultiplier(w.provider, marketIndex),
    getSyntheticTokenPrices: _ => syntheticTokenPrices(w.provider, marketIndex),
    getExposures: _ => exposures(w.provider, marketIndex),
    getUnconfirmedExposures: _ => unconfirmedExposures(w.provider, marketIndex),
    getFundingRateAprs: _ => fundingRateAprs(w.provider, marketIndex),
    getPositions: positions(w.provider, marketIndex),
    getStakedPositions: stakedPositions(w.provider, marketIndex),
    getUnsettledPositions: unsettledPositions(w.provider, marketIndex),
    claimFloatCustomFor: claimFloatCustomFor(w, [marketIndex]),
    settleOutstandingActions: settleOutstandingActions(w, marketIndex),
    updateSystemState: updateSystemState(w, marketIndex),
    getSide: isLong => MarketSide.makeWithWallet(w, marketIndex, isLong),
  }
}

let makeWithProvider = (p: providerType, marketIndex: BigNumber.t): marketWithProvider => {
  {
    getLeverage: _ => leverage(p, marketIndex),
    getFundingRateMultiplier: _ => MarketSide.fundingRateMultiplier(p, marketIndex),
    getSyntheticTokenPrices: _ => syntheticTokenPrices(p, marketIndex),
    getExposures: _ => exposures(p, marketIndex),
    getUnconfirmedExposures: _ => unconfirmedExposures(p, marketIndex),
    getFundingRateAprs: _ => fundingRateAprs(p, marketIndex),
    getPositions: positions(p, marketIndex),
    getStakedPositions: stakedPositions(p, marketIndex),
    getUnsettledPositions: unsettledPositions(p, marketIndex),
    getSide: isLong => MarketSide.makeWithProvider(p, marketIndex, isLong),
    connect: w => makeWithWallet(w, marketIndex),
  }
}
