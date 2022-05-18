open FloatContracts
open FloatEthers
open FloatUtil
open Promise
open FloatConfig

let {min, max, div, mul, add, sub, fromInt, fromFloat, toNumber, toNumberFloat, tenToThe18, tenToThe14} = module(
  FloatEthers.BigNumber
)

type positions = {
  paymentToken: BigNumber.t,
  synthToken: BigNumber.t,
}

type marketSideWithWallet = {
  token: Promise.t<FloatConfig.erc20>,
  name: Promise.t<string>,
  getValue: unit => Promise.t<FloatEthers.BigNumber.t>,
  getSyntheticTokenPrice: unit => Promise.t<FloatEthers.BigNumber.t>,
  getExposure: unit => Promise.t<FloatEthers.BigNumber.t>,
  getUnconfirmedExposure: unit => Promise.t<FloatEthers.BigNumber.t>,
  getFundingRateApr: unit => Promise.t<float>,
  getPositions: unit => Promise.t<positions>,
  getStakedPositions: unit => Promise.t<positions>,
  getUnsettledPositions: unit => Promise.t<positions>,
  mint: (BigNumber.t, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  mintAndStake: (BigNumber.t, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  stake: (BigNumber.t, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  unstake: (BigNumber.t, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  redeem: (BigNumber.t, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  shift: (BigNumber.t, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  shiftStake: (BigNumber.t, txOptions) => Promise.t<FloatEthers.txSubmitted>,
}

type marketSideWithProvider = {
  token: Promise.t<FloatConfig.erc20>,
  name: Promise.t<string>,
  getValue: unit => Promise.t<FloatEthers.BigNumber.t>,
  getSyntheticTokenPrice: unit => Promise.t<FloatEthers.BigNumber.t>,
  getExposure: unit => Promise.t<FloatEthers.BigNumber.t>,
  getUnconfirmedExposure: unit => Promise.t<FloatEthers.BigNumber.t>,
  getFundingRateApr: unit => Promise.t<float>,
  getPositions: ethAddress => Promise.t<positions>,
  getStakedPositions: ethAddress => Promise.t<positions>,
  getUnsettledPositions: ethAddress => Promise.t<positions>,
  connect: walletType => marketSideWithWallet,
}

let makeLongShortContract = (p: providerOrWallet, c: chainConfigShape) =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

// TODO was getting weird type error here
//let makeSynth = (p: providerOrWallet, address: ethAddress) =>
//    Synth.make(~address, ~providerOrWallet=p)

let makeStakerContract = (p: providerOrWallet, c: chainConfigShape) =>
  Staker.make(~address=c.contracts.longShort.address->Utils.getAddressUnsafe, ~providerOrWallet=p)

let syntheticTokenAddress = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
) => p->wrapProvider->makeLongShortContract(c)->LongShort.syntheticTokens(~marketIndex, ~isLong)

let syntheticTokenTotalSupply = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
) =>
  p
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=p->wrapProvider)))
  ->then(synth => synth->Synth.totalSupply)

let syntheticTokenBalance = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  owner: ethAddress,
) =>
  p
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=p->wrapProvider)))
  ->then(synth => synth->Synth.balanceOf(~owner))

let stakedSyntheticTokenBalance = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  owner: ethAddress,
) =>
  p
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(token => p->wrapProvider->makeStakerContract(c)->Staker.userAmountStaked(~token, ~owner))

let marketSideValue = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
) =>
  p
  ->wrapProvider
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
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  user: ethAddress,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.userNextPrice_currentUpdateIndex(~marketIndex, ~user)

let unsettledSynthBalance = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  user: ethAddress,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.getUsersConfirmedButNotSettledSynthBalance(~marketIndex, ~isLong, ~user)

let marketSideUnconfirmedDeposits = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.batched_amountPaymentToken_deposit(~marketIndex, ~isLong)

let marketSideUnconfirmedRedeems = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.batched_amountSyntheticToken_redeem(~marketIndex, ~isLong)

let marketSideUnconfirmedShifts = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isShiftFromLong: bool,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.batched_amountSyntheticToken_toShiftAwayFrom_marketSide(
    ~marketIndex,
    ~isLong=isShiftFromLong,
  )

let syntheticTokenPrice = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
) =>
  all2((
    marketSideValue(p, c, marketIndex, isLong),
    syntheticTokenTotalSupply(p, c, marketIndex, isLong),
  ))->thenResolve(((value, total)) =>
    value->mul(tenToThe18)->div(total)
  )

let syntheticTokenPriceSnapshot = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  priceSnapshotIndex: BigNumber.t,
) =>
  p
  ->wrapProvider
  ->makeLongShortContract(c)
  ->LongShort.get_syntheticToken_priceSnapshot_side(~marketIndex, ~isLong, ~priceSnapshotIndex)

let marketSideValues = (p: providerType, c: chainConfigShape, marketIndex: BigNumber.t): Promise.t<
  LongShort.marketSideValue,
> =>
  p->wrapProvider->makeLongShortContract(c)->LongShort.marketSideValueInPaymentToken(~marketIndex)

let exposure = (p: providerType, c: chainConfigShape, marketIndex: BigNumber.t, isLong: bool) =>
  marketSideValues(p, c, marketIndex)->thenResolve(values => {
    let numerator = values.long->min(values.short)->mul(tenToThe18)
    switch isLong {
    | true => numerator->div(values.long)
    | false => numerator->div(values.short)
    }
  })

let unconfirmedExposure = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
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
  c: chainConfigShape,
  marketIndex: BigNumber.t,
): Promise.t<float> =>
  p
  ->wrapProvider
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
  c: chainConfigShape,
  marketIndex: BigNumber.t,
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
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  address: ethAddress,
) =>
  all2((
    syntheticTokenBalance(p, c, marketIndex, isLong, address),
    syntheticTokenPrice(p, c, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    synthToken: balance,
  })

let stakedPositions = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  address: ethAddress,
) =>
  all2((
    stakedSyntheticTokenBalance(p, c, marketIndex, isLong, address),
    syntheticTokenPrice(p, c, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    synthToken: balance,
  })

// TODO add users unconfirmed positions

let unsettledPositions = (
  p: providerType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
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
    synthToken: balance,
  })

let mint = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountPaymentToken: BigNumber.t,
) =>
  switch isLong {
  | true =>
    w
    ->wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.mintLongNextPrice(~marketIndex, ~amountPaymentToken)
  | false =>
    w
    ->wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.mintShortNextPrice(~marketIndex, ~amountPaymentToken)
  }

let mintAndStake = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountPaymentToken: BigNumber.t,
) =>
  w
  ->wrapWallet
  ->makeLongShortContract(c)
  ->LongShort.mintAndStakeNextPrice(~marketIndex, ~amountPaymentToken, ~isLong)

let stake = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
  txOptions: txOptions,
) =>
  w.provider
  ->syntheticTokenAddress(c, marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=w->wrapWallet)))
  ->then(synth => synth->Synth.stake(~amountSyntheticToken, txOptions))

let unstake = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  w
  ->wrapWallet
  ->makeStakerContract(c)
  ->Staker.withdraw(~marketIndex, ~isWithdrawFromLong=isLong, ~amountSyntheticToken)

let redeem = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  switch isLong {
  | true =>
    w
    ->wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.redeemLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    w
    ->wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.redeemShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shift = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  switch isLong {
  | true =>
    w
    ->wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.shiftPositionFromLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    w
    ->wrapWallet
    ->makeLongShortContract(c)
    ->LongShort.shiftPositionFromShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shiftStake = (
  w: walletType,
  c: chainConfigShape,
  marketIndex: BigNumber.t,
  isLong: bool,
  amountSyntheticToken: BigNumber.t,
) =>
  w
  ->wrapWallet
  ->makeStakerContract(c)
  ->Staker.shiftTokens(~amountSyntheticToken, ~marketIndex, ~isShiftFromLong=isLong)

// TODO we should not be using getAddressUnsafe
//   rather we should do error handling properly
let makeWithWallet = (w: walletType, marketIndex: int, isLong: bool) => {
  {
    token: w
    ->wrapWallet
    ->getChainConfig
    ->thenResolve(c =>
      switch isLong {
      | true => c.markets[marketIndex].longToken
      | false => c.markets[marketIndex].shortToken
      }
    ),
    name: w
    ->wrapWallet
    ->getChainConfig
    ->thenResolve(c =>
      switch isLong {
      | true => "long"
      | false => "short"
      }
    ),
    getValue: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => marketSideValue(w.provider, c, marketIndex->BigNumber.fromInt, isLong)),
    getSyntheticTokenPrice: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => syntheticTokenPrice(w.provider, c, marketIndex->BigNumber.fromInt, isLong)),
    getExposure: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => exposure(w.provider, c, marketIndex->BigNumber.fromInt, isLong)),
    getUnconfirmedExposure: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => unconfirmedExposure(w.provider, c, marketIndex->BigNumber.fromInt, isLong)),
    getFundingRateApr: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c => fundingRateApr(w.provider, c, marketIndex->BigNumber.fromInt, isLong)),
    getPositions: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        positions(
          w.provider,
          c,
          marketIndex->BigNumber.fromInt,
          isLong,
          w.address->Utils.getAddressUnsafe,
        )
      ),
    getStakedPositions: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        stakedPositions(
          w.provider,
          c,
          marketIndex->BigNumber.fromInt,
          isLong,
          w.address->Utils.getAddressUnsafe,
        )
      ),
    getUnsettledPositions: _ =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        unsettledPositions(
          w.provider,
          c,
          marketIndex->BigNumber.fromInt,
          isLong,
          w.address->Utils.getAddressUnsafe,
        )
      ),
    mint: (amountPaymentToken, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        mint(w, c, marketIndex->BigNumber.fromInt, isLong, amountPaymentToken, txOptions)
      ),
    mintAndStake: (amountPaymentToken, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        mintAndStake(w, c, marketIndex->BigNumber.fromInt, isLong, amountPaymentToken, txOptions)
      ),
    stake: (amountSyntheticToken, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        stake(w, c, marketIndex->BigNumber.fromInt, isLong, amountSyntheticToken, txOptions)
      ),
    unstake: (amountSyntheticToken, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        unstake(w, c, marketIndex->BigNumber.fromInt, isLong, amountSyntheticToken, txOptions)
      ),
    redeem: (amountSyntheticToken, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        redeem(w, c, marketIndex->BigNumber.fromInt, isLong, amountSyntheticToken, txOptions)
      ),
    shift: (amountSyntheticToken, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        shift(w, c, marketIndex->BigNumber.fromInt, isLong, amountSyntheticToken, txOptions)
      ),
    shiftStake: (amountSyntheticToken, txOptions) =>
      w
      ->wrapWallet
      ->getChainConfig
      ->then(c =>
        shiftStake(w, c, marketIndex->BigNumber.fromInt, isLong, amountSyntheticToken, txOptions)
      ),
  }
}

let makeWithProvider = (p: providerType, marketIndex: int, isLong: bool) => {
  {
    token: p
    ->wrapProvider
    ->getChainConfig
    ->thenResolve(c =>
      switch isLong {
      | true => c.markets[marketIndex].longToken
      | false => c.markets[marketIndex].shortToken
      }
    ),
    name: p
    ->wrapProvider
    ->getChainConfig
    ->thenResolve(c =>
      switch isLong {
      | true => "long"
      | false => "short"
      }
    ),
    getValue: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => marketSideValue(p, c, marketIndex->BigNumber.fromInt, isLong)),
    getSyntheticTokenPrice: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => syntheticTokenPrice(p, c, marketIndex->BigNumber.fromInt, isLong)),
    getExposure: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => exposure(p, c, marketIndex->BigNumber.fromInt, isLong)),
    getUnconfirmedExposure: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => unconfirmedExposure(p, c, marketIndex->BigNumber.fromInt, isLong)),
    getFundingRateApr: _ =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => fundingRateApr(p, c, marketIndex->BigNumber.fromInt, isLong)),
    getPositions: ethAddress =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => positions(p, c, marketIndex->BigNumber.fromInt, isLong, ethAddress)),
    getStakedPositions: ethAddress =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => stakedPositions(p, c, marketIndex->BigNumber.fromInt, isLong, ethAddress)),
    getUnsettledPositions: ethAddress =>
      p
      ->wrapProvider
      ->getChainConfig
      ->then(c => unsettledPositions(p, c, marketIndex->BigNumber.fromInt, isLong, ethAddress)),
    connect: w => makeWithWallet(w, marketIndex, isLong),
  }
}
