open Contracts
open Ethers
open ConfigMain
open Promise

let {min, div, mul, add, sub} = module(Ethers.BigNumber)

module MarketSide = {
  type b = {
    paymentToken: BigNumber.t,
    synthToken: BigNumber.t,
  }

  type a = {
    getSyntheticTokenPrice: unit => Promise.t<Ethers.BigNumber.t>,
    getExposure: unit => Promise.t<Ethers.BigNumber.t>,
    getUnconfirmedExposure: unit => Promise.t<Ethers.BigNumber.t>,
    getPositions: ethAddress => Promise.t<b>,
    getStakedPositions: ethAddress => Promise.t<b>,
    getUnsettledPositions: ethAddress => Promise.t<b>,
  }

  let makeLongShortContract = (p: providerOrSigner) =>
    LongShort.make(
      ~address=polygonConfig.longShortContractAddress->Utils.getAddressUnsafe,
      ~providerOrSigner=p,
    )

  // TODO was getting weird type error here
  //let makeSynth = (p: providerOrSigner, address: ethAddress) =>
  //    Synth.make(~address, ~providerOrSigner=p)

  let makeStakerContract = (p: providerOrSigner) =>
    Staker.make(
      ~address=polygonConfig.stakerContractAddress->Utils.getAddressUnsafe,
      ~providerOrSigner=p,
    )

  let syntheticTokenAddress = (p: providerOrSigner, marketIndex: BigNumber.t, isLong: bool) =>
    p->makeLongShortContract->LongShort.syntheticTokens(~marketIndex, ~isLong)

  let syntheticTokenTotalSupply = (p: providerOrSigner, marketIndex: BigNumber.t, isLong: bool) =>
    p
    ->syntheticTokenAddress(marketIndex, isLong)
    ->then(address => resolve(address->Synth.make(~providerOrSigner=p)))
    ->then(synth => synth->Synth.totalSupply)

  let syntheticTokenBalance = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isLong: bool,
    owner: ethAddress,
  ) =>
    p
    ->syntheticTokenAddress(marketIndex, isLong)
    ->then(address => resolve(address->Synth.make(~providerOrSigner=p)))
    ->then(synth => synth->Synth.balanceOf(~owner))

  let stakedSyntheticTokenBalance = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isLong: bool,
    owner: ethAddress,
  ) =>
    p
    ->syntheticTokenAddress(marketIndex, isLong)
    ->then(token => p->makeStakerContract->Staker.userAmountStaked(~token, ~owner))

  let marketSideValues = (p: providerOrSigner, marketIndex: BigNumber.t): Promise.t<
    LongShort.marketSideValue,
  > => p->makeLongShortContract->LongShort.marketSideValueInPaymentToken(~marketIndex)

  let marketSideValue = (p: providerOrSigner, marketIndex: BigNumber.t, isLong: bool) =>
    p
    ->makeLongShortContract
    ->LongShort.marketSideValueInPaymentToken(~marketIndex)
    ->thenResolve(marketSideValue =>
      switch isLong {
      | true => marketSideValue.long
      | false => marketSideValue.short
      }
    )

  let updateIndex = (p: providerOrSigner, marketIndex: BigNumber.t, user: ethAddress) =>
    p->makeLongShortContract->LongShort.userNextPrice_currentUpdateIndex(~marketIndex, ~user)

  let unsettledSynthBalance = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isLong: bool,
    user: ethAddress,
  ) =>
    p
    ->makeLongShortContract
    ->LongShort.getUsersConfirmedButNotSettledSynthBalance(~marketIndex, ~isLong, ~user)

  let marketSideUnconfirmedDeposits = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isLong: bool,
  ) => makeLongShortContract(p)->LongShort.batched_amountPaymentToken_deposit(~marketIndex, ~isLong)

  let marketSideUnconfirmedRedeems = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isLong: bool,
  ) =>
    makeLongShortContract(p)->LongShort.batched_amountSyntheticToken_redeem(~marketIndex, ~isLong)

  let marketSideUnconfirmedShifts = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isShiftFromLong: bool,
  ) =>
    makeLongShortContract(p)->LongShort.batched_amountSyntheticToken_toShiftAwayFrom_marketSide(
      ~marketIndex,
      ~isLong=isShiftFromLong,
    )

  let syntheticTokenPrice = (p: providerOrSigner, marketIndex: BigNumber.t, isLong: bool) =>
    all2((
      marketSideValue(p, marketIndex, isLong),
      syntheticTokenTotalSupply(p, marketIndex, isLong),
    ))->thenResolve(((value, total)) =>
      value->BigNumber.mul(CONSTANTS.tenToThe18)->BigNumber.div(total)
    )

  let syntheticTokenPriceSnapshot = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isLong: bool,
    priceSnapshotIndex: BigNumber.t,
  ) =>
    p
    ->makeLongShortContract
    ->LongShort.get_syntheticToken_priceSnapshot_side(~marketIndex, ~isLong, ~priceSnapshotIndex)

  let exposure = (p: providerOrSigner, marketIndex: BigNumber.t, isLong: bool) =>
    marketSideValues(p, marketIndex)->thenResolve(values => {
      let numerator = values.long->min(values.short)->mul(CONSTANTS.tenToThe18)
      switch isLong {
      | true => numerator->div(values.long)
      | false => numerator->div(values.short)
      }
    })

  let unconfirmedExposure = (p: providerOrSigner, marketIndex: BigNumber.t, isLong: bool) =>
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

  // TODO allow address to be inferred from providerOrSigner
  let positions = (
    p: providerOrSigner,
    marketIndex: BigNumber.t,
    isLong: bool,
    address: ethAddress,
  ) =>
    //~includeStake=false,
    //~includeNextPrice=false) =>
    all2((
      syntheticTokenBalance(p, marketIndex, isLong, address),
      syntheticTokenPrice(p, marketIndex, isLong),
    ))->thenResolve(((balance, price)) => {
      paymentToken: balance->mul(price),
      synthToken: balance,
    })

  // TODO allow address to be inferred from providerOrSigner
  let stakedPositions = (
    p: providerOrSigner,
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

  // TODO allow address to be inferred from providerOrSigner
  let unsettledPositions = (
    p: providerOrSigner,
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

  let newFloatMarketSide = (p: providerOrSigner, marketIndex: BigNumber.t, isLong: bool) => {
    {
      getSyntheticTokenPrice: _ => syntheticTokenPrice(p, marketIndex, isLong),
      getExposure: _ => exposure(p, marketIndex, isLong),
      getUnconfirmedExposure: _ => unconfirmedExposure(p, marketIndex, isLong),
      getPositions: positions(p, marketIndex, isLong),
      getStakedPositions: stakedPositions(p, marketIndex, isLong),
      getUnsettledPositions: unsettledPositions(p, marketIndex, isLong),
    }
  }
}
