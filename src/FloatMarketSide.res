open FloatContracts
open FloatUtil
open Promise

// ====================================
// Convenience

let {
  min,
  max,
  div,
  mul,
  add,
  sub,
  fromInt,
  fromFloat,
  toNumber,
  toNumberFloat,
  tenToThe18,
  tenToThe14,
} = module(FloatEthers.BigNumber)

// ====================================
// Type definitions

type bn = FloatEthers.BigNumber.t
type ethAddress = FloatEthers.ethAddress
type providerType = FloatEthers.providerType
type walletType = FloatEthers.walletType
type providerOrWallet = FloatEthers.providerOrWallet

type positions = {
  paymentToken: bn,
  syntheticToken: bn,
}

type withProvider = {provider: providerType, marketIndex: int, isLong: bool}
type withWallet = {wallet: walletType, marketIndex: int, isLong: bool}

type withProviderOrWallet =
  | P(withProvider)
  | W(withWallet)

let wrapSideP: withProvider => withProviderOrWallet = side => P(side)
let wrapSideW: withWallet => withProviderOrWallet = side => W(side)

// ====================================
// Constructors

module WithProvider = {
  type t = withProvider
  let make = (p, marketIndex, isLong) => {provider: p, marketIndex: marketIndex, isLong: isLong}
  let makeWrap = (p, marketIndex, isLong) => make(p, marketIndex, isLong)->wrapSideP
  let makeWrapReverseCurry = (isLong, marketIndex, p) => make(p, marketIndex, isLong)->wrapSideP
}

module WithWallet = {
  type t = withWallet
  let make = (w, marketIndex, isLong) => {wallet: w, marketIndex: marketIndex, isLong: isLong}
  let makeWrap = (w, marketIndex, isLong) => make(w, marketIndex, isLong)->wrapSideW
}

// ====================================
// Helper functions

let provider = (side: withProviderOrWallet) =>
  switch side {
  | P(s) => s.provider
  | W(s) => s.wallet.provider
  }

let isLong = (side: withProviderOrWallet) =>
  switch side {
  | P(s) => s.isLong
  | W(s) => s.isLong
  }

let marketIndex = (side: withProviderOrWallet) =>
  switch side {
  | P(s) => s.marketIndex
  | W(s) => s.marketIndex
  }

// TODO we should not be using getAddressUnsafe
//   rather we should do error handling properly
let makeLongShortContract = (p: providerOrWallet, c: FloatConfig.chainConfigShape) =>
  LongShort.make(
    ~address=c.contracts.longShort.address->FloatEthers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let makeStakerContract = (p: providerOrWallet, c: FloatConfig.chainConfigShape) =>
  Staker.make(
    ~address=c.contracts.longShort.address->FloatEthers.Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let syntheticTokenAddress = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.syntheticTokens(~marketIndex, ~isLong)

let syntheticTokenTotalSupply = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
) =>
  p
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=p->FloatEthers.wrapProvider)))
  ->then(synth => synth->Synth.totalSupply)

let syntheticTokenBalance = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  owner: ethAddress,
) =>
  p
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=p->FloatEthers.wrapProvider)))
  ->then(synth => synth->Synth.balanceOf(~owner))

let stakedSyntheticTokenBalance = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  owner: ethAddress,
) =>
  p
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(token =>
    p->FloatEthers.wrapProvider->makeStakerContract(c)->Staker.userAmountStaked(~token, ~owner)
  )

let marketSideValue = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.marketSideValueInPaymentToken(~marketIndex)
  ->thenResolve(value =>
    switch isLong {
    | true => value.long
    | false => value.short
    }
  )

let updateIndex = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  user: ethAddress,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.userNextPrice_currentUpdateIndex(~marketIndex, ~user)

let unsettledSynthBalance = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  user: ethAddress,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.getUsersConfirmedButNotSettledSynthBalance(~marketIndex, ~isLong, ~user)

let marketSideUnconfirmedDeposits = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.batched_amountPaymentToken_deposit(~marketIndex, ~isLong)

let marketSideUnconfirmedRedeems = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.batched_amountSyntheticToken_redeem(~marketIndex, ~isLong)

let marketSideUnconfirmedShifts = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isShiftFromLong: bool,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.batched_amountSyntheticToken_toShiftAwayFrom_marketSide(
    ~marketIndex,
    ~isLong=isShiftFromLong,
  )

let syntheticTokenPrice = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
) =>
  all2((
    marketSideValue(p, c, marketIndex, isLong),
    syntheticTokenTotalSupply(p, c, marketIndex, isLong),
  ))->thenResolve(((value, total)) => value->mul(tenToThe18)->div(total))

let syntheticTokenPriceSnapshot = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  priceSnapshotIndex: bn,
) =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.get_syntheticToken_priceSnapshot_side(~marketIndex, ~isLong, ~priceSnapshotIndex)

let marketSideValues = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
): Promise.t<LongShort.marketSideValue> =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.marketSideValueInPaymentToken(~marketIndex)

let exposure = (p: providerType, c: FloatConfig.chainConfigShape, marketIndex: bn, isLong: bool) =>
  marketSideValues(p, c, marketIndex)->thenResolve(values => {
    let numerator = values.long->min(values.short)->mul(tenToThe18)
    switch isLong {
    | true => numerator->div(values.long)
    | false => numerator->div(values.short)
    }
  })

let unconfirmedExposure = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
) =>
  all([
    syntheticTokenPrice(p, c, marketIndex, true),
    syntheticTokenPrice(p, c, marketIndex, false),
    marketSideUnconfirmedRedeems(p, c, marketIndex, true),
    marketSideUnconfirmedRedeems(p, c, marketIndex, false),
    marketSideUnconfirmedShifts(p, c, marketIndex, true),
    marketSideUnconfirmedShifts(p, c, marketIndex, false),
    marketSideUnconfirmedDeposits(p, c, marketIndex, true),
    marketSideUnconfirmedDeposits(p, c, marketIndex, false),
    marketSideValue(p, c, marketIndex, true),
    marketSideValue(p, c, marketIndex, false),
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
      ->div(tenToThe18)
      ->add(depositsLong)
      ->add(valueLong)

    let unconfirmedValueShort =
      shiftsFromLong
      ->sub(shiftsFromShort)
      ->sub(redeemsShort)
      ->mul(priceShort)
      ->div(tenToThe18)
      ->add(depositsShort)
      ->add(valueShort)

    let numerator = unconfirmedValueLong->min(unconfirmedValueShort)->mul(tenToThe18)

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
let fundingRateMultiplier = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
): Promise.t<float> =>
  p
  ->FloatEthers.wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.fundingRateMultiplier_e18(~marketIndex)
  ->thenResolve(m => m->div(tenToThe18)->toNumberFloat)

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
let fundingRateApr = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
): Promise.t<float> =>
  all2((
    fundingRateMultiplier(p, c, marketIndex),
    marketSideValues(p, c, marketIndex),
  ))->thenResolve(((m, {long, short})) =>
    short
    ->sub(long)
    ->mul(isLong->toSign->fromInt)
    ->mul(m->fromFloat)
    ->mul(tenToThe18)
    ->div(longOrShort(long, short, isLong))
    ->div(tenToThe14)
    ->toNumberFloat
    ->divFloat(100.0)
  )

let positions = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  address: ethAddress,
) =>
  all2((
    syntheticTokenBalance(p, c, marketIndex, isLong, address),
    syntheticTokenPrice(p, c, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    syntheticToken: balance,
  })

let stakedPositions = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  address: ethAddress,
) =>
  all2((
    stakedSyntheticTokenBalance(p, c, marketIndex, isLong, address),
    syntheticTokenPrice(p, c, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    syntheticToken: balance,
  })

// TODO add users unconfirmed positions

let unsettledPositions = (
  p: providerType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  address: ethAddress,
) =>
  updateIndex(p, c, marketIndex, address)
  ->then(index =>
    all2((
      syntheticTokenPriceSnapshot(p, c, marketIndex, isLong, index),
      unsettledSynthBalance(p, c, marketIndex, isLong, address),
    ))
  )
  ->thenResolve(((price, balance)) => {
    paymentToken: balance->mul(price),
    syntheticToken: balance,
  })

let mint = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  amountPaymentToken: bn,
) =>
  switch isLong {
  | true =>
    w
    ->FloatEthers.wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.mintLongNextPrice(~marketIndex, ~amountPaymentToken)
  | false =>
    w
    ->FloatEthers.wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.mintShortNextPrice(~marketIndex, ~amountPaymentToken)
  }

let mintAndStake = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  amountPaymentToken: bn,
) =>
  w
  ->FloatEthers.wrapWallet
  ->makeLongShortContract(c)
  ->LongShort.mintAndStakeNextPrice(~marketIndex, ~amountPaymentToken, ~isLong)

let stake = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  amountSyntheticToken: bn,
  txOptions: txOptions,
) =>
  w.provider
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=w->FloatEthers.wrapWallet)))
  ->then(synth => synth->Synth.stake(~amountSyntheticToken, txOptions))

let unstake = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  amountSyntheticToken: bn,
) =>
  w
  ->FloatEthers.wrapWallet
  ->makeStakerContract(c)
  ->Staker.withdraw(~marketIndex, ~isWithdrawFromLong=isLong, ~amountSyntheticToken)

let redeem = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  amountSyntheticToken: bn,
) =>
  switch isLong {
  | true =>
    w
    ->FloatEthers.wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.redeemLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    w
    ->FloatEthers.wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.redeemShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shift = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  amountSyntheticToken: bn,
) =>
  switch isLong {
  | true =>
    w
    ->FloatEthers.wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.shiftPositionFromLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    w
    ->FloatEthers.wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.shiftPositionFromShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shiftStake = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndex: bn,
  isLong: bool,
  amountSyntheticToken: bn,
) =>
  w
  ->FloatEthers.wrapWallet
  ->makeStakerContract(c)
  ->Staker.shiftTokens(~amountSyntheticToken, ~marketIndex, ~isShiftFromLong=isLong)

// ====================================
// Export functions

let syntheticToken = (side: withProviderOrWallet) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->thenResolve(config =>
    switch side->isLong {
    | true => config.markets[side->marketIndex].longToken
    | false => config.markets[side->marketIndex].shortToken
    }
  )

let name = (side: withProviderOrWallet) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->thenResolve(_ =>
    switch side->isLong {
    | true => "long"
    | false => "short"
    }
  )

let poolValue = (side: withProviderOrWallet) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->marketSideValue(config, side->marketIndex->fromInt, side->isLong)
  )

let syntheticTokenPrice = (side: withProviderOrWallet) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->syntheticTokenPrice(config, side->marketIndex->fromInt, side->isLong)
  )

let exposure = (side: withProviderOrWallet) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => side->provider->exposure(config, side->marketIndex->fromInt, side->isLong))

let unconfirmedExposure = (side: withProviderOrWallet) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->unconfirmedExposure(config, side->marketIndex->fromInt, side->isLong)
  )

let fundingRateApr = (side: withProviderOrWallet) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config => side->provider->fundingRateApr(config, side->marketIndex->fromInt, side->isLong))

let positions = (side: withProviderOrWallet, ethAddress) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->positions(config, side->marketIndex->fromInt, side->isLong, ethAddress)
  )

let stakedPositions = (side: withProviderOrWallet, ethAddress) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->stakedPositions(config, side->marketIndex->fromInt, side->isLong, ethAddress)
  )

let unsettledPositions = (side: withProviderOrWallet, ethAddress) =>
  side
  ->provider
  ->FloatEthers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->unsettledPositions(config, side->marketIndex->fromInt, side->isLong, ethAddress)
  )

let mint = (side: withWallet, amountPaymentToken, txOptions) =>
  side.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(config =>
    side.wallet->mint(
      config,
      side->wrapSideW->marketIndex->fromInt,
      side->wrapSideW->isLong,
      amountPaymentToken,
      txOptions,
    )
  )

let mintAndStake = (side: withWallet, amountPaymentToken, txOptions) =>
  side.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(c =>
    side.wallet->mintAndStake(
      c,
      side->wrapSideW->marketIndex->fromInt,
      side->wrapSideW->isLong,
      amountPaymentToken,
      txOptions,
    )
  )

let stake = (side: withWallet, amountSyntheticToken, txOptions) =>
  side.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(c =>
    side.wallet->stake(
      c,
      side->wrapSideW->marketIndex->fromInt,
      side->wrapSideW->isLong,
      amountSyntheticToken,
      txOptions,
    )
  )

let unstake = (side: withWallet, amountSyntheticToken, txOptions) =>
  side.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(c =>
    side.wallet->unstake(
      c,
      side->wrapSideW->marketIndex->fromInt,
      side->wrapSideW->isLong,
      amountSyntheticToken,
      txOptions,
    )
  )

let redeem = (side: withWallet, amountSyntheticToken, txOptions) =>
  side.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(c =>
    side.wallet->redeem(
      c,
      side->wrapSideW->marketIndex->fromInt,
      side->wrapSideW->isLong,
      amountSyntheticToken,
      txOptions,
    )
  )

let shift = (side: withWallet, amountSyntheticToken, txOptions) =>
  side.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(c =>
    side.wallet->shift(
      c,
      side->wrapSideW->marketIndex->fromInt,
      side->wrapSideW->isLong,
      amountSyntheticToken,
      txOptions,
    )
  )

let shiftStake = (side: withWallet, amountSyntheticToken, txOptions) =>
  side.wallet
  ->FloatEthers.wrapWallet
  ->getChainConfig
  ->then(c =>
    side.wallet->shiftStake(
      c,
      side->wrapSideW->marketIndex->fromInt,
      side->wrapSideW->isLong,
      amountSyntheticToken,
      txOptions,
    )
  )
