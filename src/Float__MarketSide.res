open Float__Contracts
open Float__Util
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
} = module(Float__Ethers.BigNumber)

// ====================================
// Type definitions

type positions = {
  paymentToken: Float__Ethers.BigNumber.t,
  syntheticToken: Float__Ethers.BigNumber.t,
}

type withProvider = {provider: Float__Ethers.providerType, marketIndex: int, isLong: bool}
type withWallet = {wallet: Float__Ethers.walletType, marketIndex: int, isLong: bool}

type withProviderOrWallet =
  | P(withProvider)
  | W(withWallet)

let wrapSideP: withProvider => withProviderOrWallet = side => P(side)
let wrapSideW: withWallet => withProviderOrWallet = side => W(side)

// ====================================
// Constructors

module WithProvider = {
  type t = withProvider

  // the unwrapped version is not the default but may be useful for rescript consumers
  //   that don't want to have to do a switch statement
  let makeUnwrapped = (p, marketIndex, isLong) => {provider: p, marketIndex: marketIndex, isLong: isLong}
  let make = (p, marketIndex, isLong) => makeUnwrapped(p, marketIndex, isLong)->wrapSideP

  // this is just a convenience file that is used inside this repo,
  //   but it may be useful to consumers so why not leave it public
  let makeReverseCurry = (isLong, marketIndex, p) => makeUnwrapped(p, marketIndex, isLong)->wrapSideP

  // default provider can also be used
  let makeDefault = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->make
  let makeDefaultUnwrapped = chainId => chainId->getChainConfigUsingId->makeDefaultProvider->makeUnwrapped
}

module WithWallet = {
  type t = withWallet
  let makeUnwrapped = (w, marketIndex, isLong) => {wallet: w, marketIndex: marketIndex, isLong: isLong}
  let make = (w, marketIndex, isLong) => makeUnwrapped(w, marketIndex, isLong)->wrapSideW
}

let makeUsingMarket = (market, isLong) =>
  switch market {
  | Float__Market__shared.P(m) => m.provider->WithProvider.make(m.marketIndex, isLong)
  | Float__Market__shared.W(m) => m.wallet->WithWallet.make(m.marketIndex, isLong)
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
  let isLong = (side: withProviderOrWallet) =>
    switch side {
    | P(s) => s.isLong
    | W(s) => s.isLong
    }
)

%%private(
  let marketIndex = (side: withProviderOrWallet) =>
    switch side {
    | P(s) => s.marketIndex
    | W(s) => s.marketIndex
    }
)

%%private(
  let longOrShort = (long, short, isLong) =>
    switch isLong {
    | true => long
    | false => short
    }
)

%%private(
  let toSign = isLong =>
    switch isLong {
    | true => 1
    | false => -1
    }
)

%%private(let divFloat = (a: float, b: float) => a /. b)

// ====================================
// Base functions

// TODO we should not be using getAddressUnsafe
//   rather we should do error handling properly
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

let syntheticTokenAddress = (provider, config, marketIndex, isLong) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.syntheticTokens(~marketIndex, ~isLong)

let syntheticTokenTotalSupply = (provider, config, marketIndex, isLong) =>
  provider
  ->syntheticTokenAddress(config, marketIndex, isLong)
  ->then(address =>
    resolve(address->Synth.make(~providerOrWallet=provider->Float__Ethers.wrapProvider))
  )
  ->then(synth => synth->Synth.totalSupply)

let syntheticTokenBalance = (provider, config, marketIndex, isLong, owner) =>
  provider
  ->syntheticTokenAddress(config, marketIndex, isLong)
  ->then(address =>
    resolve(address->Synth.make(~providerOrWallet=provider->Float__Ethers.wrapProvider))
  )
  ->then(synth => synth->Synth.balanceOf(~owner))

let stakedSyntheticTokenBalance = (provider, config, marketIndex, isLong, owner) =>
  provider
  ->syntheticTokenAddress(config, marketIndex, isLong)
  ->then(token =>
    provider
    ->Float__Ethers.wrapProvider
    ->makeStakerContract(config)
    ->Staker.userAmountStaked(~token, ~owner)
  )

let marketSideValue = (provider, config, marketIndex, isLong) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.marketSideValueInPaymentToken(~marketIndex)
  ->thenResolve(value =>
    switch isLong {
    | true => value.long
    | false => value.short
    }
  )

let updateIndex = (provider, config, marketIndex, user) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.userNextPrice_currentUpdateIndex(~marketIndex, ~user)

let unsettledSynthBalance = (provider, config, marketIndex, isLong, user) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.getUsersConfirmedButNotSettledSynthBalance(~marketIndex, ~isLong, ~user)

let marketSideUnconfirmedDeposits = (provider, config, marketIndex, isLong) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.batched_amountPaymentToken_deposit(~marketIndex, ~isLong)

let marketSideUnconfirmedRedeems = (provider, config, marketIndex, isLong) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.batched_amountSyntheticToken_redeem(~marketIndex, ~isLong)

let marketSideUnconfirmedShifts = (provider, config, marketIndex, isShiftFromLong) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.batched_amountSyntheticToken_toShiftAwayFrom_marketSide(
    ~marketIndex,
    ~isLong=isShiftFromLong,
  )

let syntheticTokenPrice = (provider, config, marketIndex, isLong) =>
  all2((
    marketSideValue(provider, config, marketIndex, isLong),
    syntheticTokenTotalSupply(provider, config, marketIndex, isLong),
  ))->thenResolve(((value, total)) => value->mul(tenToThe18)->div(total))

let syntheticTokenPriceSnapshot = (provider, config, marketIndex, isLong, priceSnapshotIndex) =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.get_syntheticToken_priceSnapshot_side(~marketIndex, ~isLong, ~priceSnapshotIndex)

let marketSideValues = (provider, config, marketIndex): Promise.t<LongShort.marketSideValue> =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.marketSideValueInPaymentToken(~marketIndex)

let exposure = (provider, config, marketIndex, isLong) =>
  marketSideValues(provider, config, marketIndex)->thenResolve(values => {
    let numerator = values.long->min(values.short)->mul(tenToThe18)
    switch isLong {
    | true => numerator->div(values.long)
    | false => numerator->div(values.short)
    }
  })

let unconfirmedExposure = (provider, config, marketIndex, isLong) =>
  all([
    syntheticTokenPrice(provider, config, marketIndex, true),
    syntheticTokenPrice(provider, config, marketIndex, false),
    marketSideUnconfirmedRedeems(provider, config, marketIndex, true),
    marketSideUnconfirmedRedeems(provider, config, marketIndex, false),
    marketSideUnconfirmedShifts(provider, config, marketIndex, true),
    marketSideUnconfirmedShifts(provider, config, marketIndex, false),
    marketSideUnconfirmedDeposits(provider, config, marketIndex, true),
    marketSideUnconfirmedDeposits(provider, config, marketIndex, false),
    marketSideValue(provider, config, marketIndex, true),
    marketSideValue(provider, config, marketIndex, false),
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

// This should really be in the Market.res file but the compiler complains about a dependency cycle
let fundingRateMultiplier = (provider, config, marketIndex): Promise.t<float> =>
  provider
  ->Float__Ethers.wrapProvider
  ->makeLongShortContract(config)
  ->LongShort.fundingRateMultiplier_e18(~marketIndex)
  ->thenResolve(m => m->div(tenToThe18)->toNumberFloat)

/*
Returns percentage APR.

+ve when
- isLong AND long < short
- !isLong AND long > short

-ve when
- !isLong AND long < short
- isLong AND long > short
*/
let fundingRateApr = (provider, config, marketIndex, isLong): Promise.t<float> =>
  all2((
    fundingRateMultiplier(provider, config, marketIndex),
    marketSideValues(provider, config, marketIndex),
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

let positions = (provider, config, marketIndex, isLong, address) =>
  all2((
    syntheticTokenBalance(provider, config, marketIndex, isLong, address),
    syntheticTokenPrice(provider, config, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    syntheticToken: balance,
  })

let stakedPositions = (provider, config, marketIndex, isLong, address) =>
  all2((
    stakedSyntheticTokenBalance(provider, config, marketIndex, isLong, address),
    syntheticTokenPrice(provider, config, marketIndex, isLong),
  ))->thenResolve(((balance, price)) => {
    paymentToken: balance->mul(price),
    syntheticToken: balance,
  })

let unsettledPositions = (provider, config, marketIndex, isLong, address) =>
  updateIndex(provider, config, marketIndex, address)
  ->then(index =>
    all2((
      syntheticTokenPriceSnapshot(provider, config, marketIndex, isLong, index),
      unsettledSynthBalance(provider, config, marketIndex, isLong, address),
    ))
  )
  ->thenResolve(((price, balance)) => {
    paymentToken: balance->mul(price),
    syntheticToken: balance,
  })

let mint = (wallet, config, marketIndex, isLong, amountPaymentToken) =>
  switch isLong {
  | true =>
    wallet
    ->Float__Ethers.wrapWallet
    ->makeLongShortContract(config)
    ->LongShort.mintLongNextPrice(~marketIndex, ~amountPaymentToken)
  | false =>
    wallet
    ->Float__Ethers.wrapWallet
    ->makeLongShortContract(config)
    ->LongShort.mintShortNextPrice(~marketIndex, ~amountPaymentToken)
  }

let mintAndStake = (wallet, config, marketIndex, isLong, amountPaymentToken) =>
  wallet
  ->Float__Ethers.wrapWallet
  ->makeLongShortContract(config)
  ->LongShort.mintAndStakeNextPrice(~marketIndex, ~amountPaymentToken, ~isLong)

let stake = (
  wallet: Float__Ethers.walletType,
  config,
  marketIndex,
  isLong,
  amountSyntheticToken,
  txOptions,
) =>
  wallet.provider
  ->syntheticTokenAddress(config, marketIndex, isLong)
  ->then(address => resolve(address->Synth.make(~providerOrWallet=wallet->Float__Ethers.wrapWallet)))
  ->then(synth => synth->Synth.stake(~amountSyntheticToken, txOptions))

let unstake = (wallet, config, marketIndex, isLong, amountSyntheticToken) =>
  wallet
  ->Float__Ethers.wrapWallet
  ->makeStakerContract(config)
  ->Staker.withdraw(~marketIndex, ~isWithdrawFromLong=isLong, ~amountSyntheticToken)

let redeem = (wallet, config, marketIndex, isLong, amountSyntheticToken) =>
  switch isLong {
  | true =>
    wallet
    ->Float__Ethers.wrapWallet
    ->makeLongShortContract(config)
    ->LongShort.redeemLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    wallet
    ->Float__Ethers.wrapWallet
    ->makeLongShortContract(config)
    ->LongShort.redeemShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shift = (wallet, config, marketIndex, isLong, amountSyntheticToken) =>
  switch isLong {
  | true =>
    wallet
    ->Float__Ethers.wrapWallet
    ->makeLongShortContract(config)
    ->LongShort.shiftPositionFromLongNextPrice(~marketIndex, ~amountSyntheticToken)
  | false =>
    wallet
    ->Float__Ethers.wrapWallet
    ->makeLongShortContract(config)
    ->LongShort.shiftPositionFromShortNextPrice(~marketIndex, ~amountSyntheticToken)
  }

let shiftStake = (wallet, config, marketIndex, isLong, amountSyntheticToken) =>
  wallet
  ->Float__Ethers.wrapWallet
  ->makeStakerContract(config)
  ->Staker.shiftTokens(~amountSyntheticToken, ~marketIndex, ~isShiftFromLong=isLong)

// TODO add users unconfirmed positions

// ====================================
// Export functions

let syntheticToken = (side: withProviderOrWallet) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
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
  ->Float__Ethers.wrapProvider
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
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->marketSideValue(config, side->marketIndex->fromInt, side->isLong)
  )

let syntheticTokenPrice = (side: withProviderOrWallet) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->syntheticTokenPrice(config, side->marketIndex->fromInt, side->isLong)
  )

let exposure = (side: withProviderOrWallet) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config => side->provider->exposure(config, side->marketIndex->fromInt, side->isLong))

let unconfirmedExposure = (side: withProviderOrWallet) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config =>
    side->provider->unconfirmedExposure(config, side->marketIndex->fromInt, side->isLong)
  )

let fundingRateApr = (side: withProviderOrWallet) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config => side->provider->fundingRateApr(config, side->marketIndex->fromInt, side->isLong))

let positions = (side: withProviderOrWallet, ~ethAddress=?, ()) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config => {
    let address = switch ethAddress {
    | Some(value) => value
    | None =>
      switch side {
      | W(s) => s.wallet.address
      | _ => {
          // TODO not a great DX but not how to make it better
          //   1 way would be to have every exported function return an option (failed or successful)
          //   and let the consuming code deal with it
          Js.log("No address found")
          ""
        }
      }
    }
    side
    ->provider
    ->positions(
      config,
      side->marketIndex->fromInt,
      side->isLong,
      address->Float__Ethers.Utils.getAddressUnsafe,
    )
  })

let stakedPositions = (side: withProviderOrWallet, ~ethAddress=?, ()) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config => {
    let address = switch ethAddress {
    | Some(value) => value
    | None =>
      switch side {
      | W(s) => s.wallet.address
      | _ => {
          // TODO not a great DX but not how to make it better
          //   1 way would be to have every exported function return an option (failed or successful)
          //   and let the consuming code deal with it
          Js.log("No address found")
          ""
        }
      }
    }
    side
    ->provider
    ->stakedPositions(
      config,
      side->marketIndex->fromInt,
      side->isLong,
      address->Float__Ethers.Utils.getAddressUnsafe,
    )
  })

let unsettledPositions = (side: withProviderOrWallet, ethAddress) =>
  side
  ->provider
  ->Float__Ethers.wrapProvider
  ->getChainConfig
  ->then(config => {
    let address = switch ethAddress {
    | Some(value) => value
    | None =>
      switch side {
      | W(s) => s.wallet.address
      | _ => {
          // TODO not a great DX but not how to make it better
          //   1 way would be to have every exported function return an option (failed or successful)
          //   and let the consuming code deal with it
          Js.log("No address found")
          ""
        }
      }
    }
    side
    ->provider
    ->unsettledPositions(
      config,
      side->marketIndex->fromInt,
      side->isLong,
      address->Float__Ethers.Utils.getAddressUnsafe,
    )
  })

let mint = (side: withWallet, amountPaymentToken, txOptions) =>
  side.wallet
  ->Float__Ethers.wrapWallet
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
  ->Float__Ethers.wrapWallet
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
  ->Float__Ethers.wrapWallet
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
  ->Float__Ethers.wrapWallet
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
  ->Float__Ethers.wrapWallet
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
  ->Float__Ethers.wrapWallet
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
  ->Float__Ethers.wrapWallet
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
