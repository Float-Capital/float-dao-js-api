open Contracts
open Ethers
open ConfigMain
open Promise

let {min, max, div, mul, add, sub, fromInt, fromFloat, toNumber, toNumberFloat} = module(
  Ethers.BigNumber
)

type positions = {
  paymentToken: BigNumber.t,
  synthToken: BigNumber.t,
}

type marketSideWithWallet = {
  getValue: unit => Promise.t<Ethers.BigNumber.t>,
  getSyntheticTokenPrice: unit => Promise.t<Ethers.BigNumber.t>,
  getExposure: unit => Promise.t<Ethers.BigNumber.t>,
  getUnconfirmedExposure: unit => Promise.t<Ethers.BigNumber.t>,
  getFundingRateApr: unit => Promise.t<float>,
  getPositions: unit => Promise.t<positions>,
  getStakedPositions: unit => Promise.t<positions>,
  getUnsettledPositions: unit => Promise.t<positions>,
  mint: (BigNumber.t, txOptions) => Promise.t<Ethers.txSubmitted>,
  mintAndStake: (BigNumber.t, txOptions) => Promise.t<Ethers.txSubmitted>,
  stake: (BigNumber.t, txOptions) => Promise.t<Ethers.txSubmitted>,
  unstake: (BigNumber.t, txOptions) => Promise.t<Ethers.txSubmitted>,
  redeem: (BigNumber.t, txOptions) => Promise.t<Ethers.txSubmitted>,
  shift: (BigNumber.t, txOptions) => Promise.t<Ethers.txSubmitted>,
  shiftStake: (BigNumber.t, txOptions) => Promise.t<Ethers.txSubmitted>,
}

type marketSideWithProvider = {
  getValue: unit => Promise.t<Ethers.BigNumber.t>,
  getSyntheticTokenPrice: unit => Promise.t<Ethers.BigNumber.t>,
  getExposure: unit => Promise.t<Ethers.BigNumber.t>,
  getUnconfirmedExposure: unit => Promise.t<Ethers.BigNumber.t>,
  getFundingRateApr: unit => Promise.t<float>,
  getPositions: ethAddress => Promise.t<positions>,
  getStakedPositions: ethAddress => Promise.t<positions>,
  getUnsettledPositions: ethAddress => Promise.t<positions>,
  connect: walletType => marketSideWithWallet,
}

let makeLongShortContract = (p: providerOrWallet) =>
  LongShort.make(
    ~address=polygonConfig.longShortContractAddress->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

// TODO was getting weird type error here
//let makeSynth = (p: providerOrWallet, address: ethAddress) =>
//    Synth.make(~address, ~providerOrWallet=p)

let makeStakerContract = (p: providerOrWallet) =>
  Staker.make(
    ~address=polygonConfig.stakerContractAddress->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let syntheticTokenAddress = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  p->wrapProvider->makeLongShortContract->LongShort.syntheticTokens(~marketIndex, ~isLong)

let syntheticTokenTotalSupply = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  p
  ->syntheticTokenAddress(marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=p->wrapProvider)))
  ->then(synth => synth->Synth.totalSupply)

let syntheticTokenBalance = (
  p: providerType,
  marketIndex: BigNumber.t,
  isLong: bool,
  owner: ethAddress,
) =>
  p
  ->syntheticTokenAddress(marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=p->wrapProvider)))
  ->then(synth => synth->Synth.balanceOf(~owner))

let stakedSyntheticTokenBalance = (
  p: providerType,
  marketIndex: BigNumber.t,
  isLong: bool,
  owner: ethAddress,
) =>
  p
  ->syntheticTokenAddress(marketIndex, isLong)
  ->then(token => p->wrapProvider->makeStakerContract->Staker.userAmountStaked(~token, ~owner))

let marketSideValue = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.marketSideValueInPaymentToken(~marketIndex)
  ->thenResolve(marketSideValue =>
    switch isLong {
    | true => marketSideValue.long
    | false => marketSideValue.short
    }
  )

let updateIndex = (p: providerType, marketIndex: BigNumber.t, user: ethAddress) =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.userNextPrice_currentUpdateIndex(~marketIndex, ~user)

let unsettledSynthBalance = (
  p: providerType,
  marketIndex: BigNumber.t,
  isLong: bool,
  user: ethAddress,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.getUsersConfirmedButNotSettledSynthBalance(~marketIndex, ~isLong, ~user)

let marketSideUnconfirmedDeposits = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.batched_amountPaymentToken_deposit(~marketIndex, ~isLong)

let marketSideUnconfirmedRedeems = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.batched_amountSyntheticToken_redeem(~marketIndex, ~isLong)

let marketSideUnconfirmedShifts = (
  p: providerType,
  marketIndex: BigNumber.t,
  isShiftFromLong: bool,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.batched_amountSyntheticToken_toShiftAwayFrom_marketSide(
    ~marketIndex,
    ~isLong=isShiftFromLong,
  )

let syntheticTokenPrice = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  all2((
    marketSideValue(p, marketIndex, isLong),
    syntheticTokenTotalSupply(p, marketIndex, isLong),
  ))->thenResolve(((value, total)) =>
    value->BigNumber.mul(CONSTANTS.tenToThe18)->BigNumber.div(total)
  )

let syntheticTokenPriceSnapshot = (
  p: providerType,
  marketIndex: BigNumber.t,
  isLong: bool,
  priceSnapshotIndex: BigNumber.t,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.get_syntheticToken_priceSnapshot_side(~marketIndex, ~isLong, ~priceSnapshotIndex)

let marketSideValues = (p: providerType, marketIndex: BigNumber.t): Promise.t<
  LongShort.marketSideValue,
> => p->wrapProvider->makeLongShortContract->LongShort.marketSideValueInPaymentToken(~marketIndex)

let exposure = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  marketSideValues(p, marketIndex)->thenResolve(values => {
    let numerator = values.long->min(values.short)->mul(CONSTANTS.tenToThe18)
    switch isLong {
    | true => numerator->div(values.long)
    | false => numerator->div(values.short)
    }
  })

let unconfirmedExposure = (p: providerType, marketIndex: BigNumber.t, isLong: bool) =>
  all([
    syntheticTokenPrice(p, marketIndex, true),
    syntheticTokenPrice(p, marketIndex, false),
    marketSideUnconfirmedRedeems(p, marketIndex, true),
    marketSideUnconfirmedRedeems(p, marketIndex, false),
    marketSideUnconfirmedShifts(p, marketIndex, true),
    marketSideUnconfirmedShifts(p, marketIndex, false),
    marketSideUnconfirmedDeposits(p, marketIndex, true),
    marketSideUnconfirmedDeposits(p, marketIndex, false),
    marketSideValue(p, marketIndex, true),
    marketSideValue(p, marketIndex, false),
  ])->thenResolve(results => {
    let priceLong = results[0]
    let priceShort = results[1]
    let redeemsLong = results[2]
    let redeemsShort = results[3]
    let shiftsFromLong = results[4]
    let shiftsFromShort = results[5]
    let depositsLong = results[6]
    let depositsShort = results[7]
    let valueLong = results[8]
    let valueShort = results[9]

    let unconfirmedValueLong =
      shiftsFromShort
      ->sub(shiftsFromLong)
      ->sub(redeemsLong)
      ->mul(priceLong)
      ->div(CONSTANTS.tenToThe18)
      ->add(depositsLong)
      ->add(valueLong)

    let unconfirmedValueShort =
      shiftsFromLong
      ->sub(shiftsFromShort)
      ->sub(redeemsShort)
      ->mul(priceShort)
      ->div(CONSTANTS.tenToThe18)
      ->add(depositsShort)
      ->add(valueShort)

    let numerator = unconfirmedValueLong->min(unconfirmedValueShort)->mul(CONSTANTS.tenToThe18)

    switch isLong {
    | true => numerator->div(unconfirmedValueLong)
    | false => numerator->div(unconfirmedValueShort)
    }
  })

let longOrShort = (long, short, isLong) =>
  switch isLong {
  | true => long
  | false => short
  }

let toSign = isLong =>
  switch isLong {
  | true => 1
  | false => -1
  }

// This should really be in the Market.res file but the compiler complains about a dependency cycle
let fundingRateMultiplier = (p: providerType, marketIndex: BigNumber.t): Promise.t<float> =>
  p
  ->wrapProvider
  ->makeLongShortContract
  ->LongShort.fundingRateMultiplier_e18(~marketIndex)
  ->thenResolve(m => m->div(CONSTANTS.tenToThe18)->toNumberFloat)

let divFloat = (a: float, b: float) => a /. b

/*
Returns percentage APR.

+ve when
- isLong AND long < short
- !isLong AND long > short

-ve when
- !isLong AND long < short
- isLong AND long > short
*/
let fundingRateApr = (p: providerType, marketIndex: BigNumber.t, isLong: bool): Promise.t<float> =>
  all2((fundingRateMultiplier(p, marketIndex), marketSideValues(p, marketIndex)))->thenResolve(((
    m,
    {long, short},
  )) =>
    short
    ->sub(long)
    ->mul(isLong->toSign->fromInt)
    ->mul(m->fromFloat)
    ->mul(CONSTANTS.tenToThe18)
    ->div(longOrShort(long, short, isLong))
    ->div(CONSTANTS.tenToThe14)
    ->toNumberFloat
    ->divFloat(100.0)
  )

let positions = (p: providerType, marketIndex: BigNumber.t, isLong: bool, address: ethAddress) =>
  all2((
    syntheticTokenBalance(p, marketIndex, isLong, address),
    syntheticTokenPrice(p, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    synthToken: balance,
  })

let stakedPositions = (
  p: providerType,
  marketIndex: BigNumber.t,
  isLong: bool,
  address: ethAddress,
) =>
  all2((
    stakedSyntheticTokenBalance(p, marketIndex, isLong, address),
    syntheticTokenPrice(p, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    synthToken: balance,
  })

// TODO add users unconfirmed positions

let unsettledPositions = (
  p: providerType,
  marketIndex: BigNumber.t,
  isLong: bool,
  address: ethAddress,
) =>
  updateIndex(p, marketIndex, address)
  ->then(index =>
    all2((
      syntheticTokenPriceSnapshot(p, marketIndex, isLong, index),
      unsettledSynthBalance(p, marketIndex, isLong, address),
    ))
  )
  ->thenResolve(((price, balance)) => {
    paymentToken: balance->mul(price),
    synthToken: balance,
  })

let mint = (
  w: walletType,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountPaymentToken: BigNumber.t,
) =>
  switch isLong {
  | true =>
    w
    ->wrapWallet
    ->makeLongShortContract
    ->LongShort.mintLongNextPrice(~marketIndex, ~amountPaymentToken)
  | false =>
    w
    ->wrapWallet
    ->makeLongShortContract
    ->LongShort.mintShortNextPrice(~marketIndex, ~amountPaymentToken)
  }

let mintAndStake = (
  w: walletType,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountPaymentToken: BigNumber.t,
) =>
  w
  ->wrapWallet
  ->makeLongShortContract
  ->LongShort.mintAndStakeNextPrice(~marketIndex, ~amountPaymentToken, ~isLong)

let stake = (
  w: walletType,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
  txOptions: txOptions,
) =>
  w.provider
  ->syntheticTokenAddress(marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=w->wrapWallet)))
  ->then(synth => synth->Synth.stake(~amountSyntheticToken, txOptions))

let unstake = (
  w: walletType,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  w
  ->wrapWallet
  ->makeStakerContract
  ->Staker.withdraw(~marketIndex, ~isWithdrawFromLong=isLong, ~amountSyntheticToken)

let redeem = (
  w: walletType,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  switch isLong {
  | true =>
    w
    ->wrapWallet
    ->makeLongShortContract
    ->LongShort.redeemLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    w
    ->wrapWallet
    ->makeLongShortContract
    ->LongShort.redeemShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shift = (
  w: walletType,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  switch isLong {
  | true =>
    w
    ->wrapWallet
    ->makeLongShortContract
    ->LongShort.shiftPositionFromLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    w
    ->wrapWallet
    ->makeLongShortContract
    ->LongShort.shiftPositionFromShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shiftStake = (
  w: walletType,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  w
  ->wrapWallet
  ->makeStakerContract
  ->Staker.shiftTokens(~amountSyntheticToken, ~marketIndex, ~isShiftFromLong=isLong)

// TODO we should not be using getAddressUnsafe
//   rather we should do error handling properly
let makeWithWallet = (w: walletType, marketIndex: BigNumber.t, isLong: bool) => {
  {
    getValue: _ => marketSideValue(w.provider, marketIndex, isLong),
    getSyntheticTokenPrice: _ => syntheticTokenPrice(w.provider, marketIndex, isLong),
    getExposure: _ => exposure(w.provider, marketIndex, isLong),
    getUnconfirmedExposure: _ => unconfirmedExposure(w.provider, marketIndex, isLong),
    getFundingRateApr: _ => fundingRateApr(w.provider, marketIndex, isLong),
    getPositions: _ =>
      positions(w.provider, marketIndex, isLong, w.address->Utils.getAddressUnsafe),
    getStakedPositions: _ =>
      stakedPositions(w.provider, marketIndex, isLong, w.address->Utils.getAddressUnsafe),
    getUnsettledPositions: _ =>
      unsettledPositions(w.provider, marketIndex, isLong, w.address->Utils.getAddressUnsafe),
    mint: mint(w, marketIndex, isLong),
    mintAndStake: mintAndStake(w, marketIndex, isLong),
    stake: stake(w, marketIndex, isLong),
    unstake: unstake(w, marketIndex, isLong),
    redeem: redeem(w, marketIndex, isLong),
    shift: shift(w, marketIndex, isLong),
    shiftStake: shiftStake(w, marketIndex, isLong),
  }
}

let makeWithProvider = (p: providerType, marketIndex: BigNumber.t, isLong: bool) => {
  {
    getValue: _ => marketSideValue(p, marketIndex, isLong),
    getSyntheticTokenPrice: _ => syntheticTokenPrice(p, marketIndex, isLong),
    getExposure: _ => exposure(p, marketIndex, isLong),
    getUnconfirmedExposure: _ => unconfirmedExposure(p, marketIndex, isLong),
    getFundingRateApr: _ => fundingRateApr(p, marketIndex, isLong),
    getPositions: positions(p, marketIndex, isLong),
    getStakedPositions: stakedPositions(p, marketIndex, isLong),
    getUnsettledPositions: unsettledPositions(p, marketIndex, isLong),
    connect: w => makeWithWallet(w, marketIndex, isLong),
  }
}
