open Contracts
open Ethers
open ConfigMain
open Promise

type bigNumbers = {
  long: Ethers.BigNumber.t,
  short: Ethers.BigNumber.t,
}

type positions = {
  long: MarketSide.positions,
  short: MarketSide.positions,
}

type marketWithProvider = {
  getLeverage: unit => Promise.t<BigNumber.t>,
  getFundingRateMultiplier: unit => Promise.t<float>,
  getSyntheticTokenPrices: unit => Promise.t<bigNumbers>,
  getExposures: unit => Promise.t<bigNumbers>,
  getUnconfirmedExposures: unit => Promise.t<bigNumbers>,
  getPositions: ethAddress => Promise.t<positions>,
  getStakedPositions: ethAddress => Promise.t<positions>,
  getUnsettledPositions: ethAddress => Promise.t<positions>,
  getSide: bool => MarketSide.marketSideWithProvider,
}

let makeLongShortContract = (p: providerOrWallet) =>
  LongShort.make(
    ~address=polygonConfig.longShortContractAddress->Utils.getAddressUnsafe,
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

let makeWithProvider = (p: providerType, marketIndex: BigNumber.t): marketWithProvider => {
  {
    getLeverage: _ => leverage(p, marketIndex),
    getFundingRateMultiplier: _ => MarketSide.fundingRateMultiplier(p, marketIndex),
    getSyntheticTokenPrices: _ => syntheticTokenPrices(p, marketIndex),
    getExposures: _ => exposures(p, marketIndex),
    getUnconfirmedExposures: _ => unconfirmedExposures(p, marketIndex),
    getPositions: positions(p, marketIndex),
    getStakedPositions: stakedPositions(p, marketIndex),
    getUnsettledPositions: unsettledPositions(p, marketIndex),
    getSide: isLong => MarketSide.makeWithProvider(p, marketIndex, isLong),
  }
}
