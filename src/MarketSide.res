open Contracts
open Ethers
open ConfigMain
open Promise

let {min, div, mul, add, sub} = module(Ethers.BigNumber)

module MarketSide = {
  type a = {
    getSyntheticTokenPrice: unit => Promise.t<Ethers.BigNumber.t>,
    getExposure: unit => Promise.t<Ethers.BigNumber.t>,
    getUnconfirmedExposure: unit => Promise.t<Ethers.BigNumber.t>,
  }

  let makeLongShortContract = providerOrSigner =>
    LongShort.make(
      ~address=polygonConfig.longShortContractAddress->Utils.getAddressUnsafe,
      ~providerOrSigner,
    )

  let syntheticTokenAddress = (providerOrSigner, marketIndex, isLong) =>
    makeLongShortContract(providerOrSigner)->LongShort.syntheticTokens(~marketIndex, ~isLong)

  let syntheticTokenTotalSupply = (providerOrSigner, marketIndex, isLong) =>
    providerOrSigner
    ->syntheticTokenAddress(marketIndex, isLong)
    ->then(address => resolve(address->Synth.make(~providerOrSigner)))
    ->then(synth => synth->Synth.totalSupply)
    ->thenResolve(supply => supply)

  let marketSideValues = (providerOrSigner, marketIndex): Promise.t<LongShort.marketSideValue> =>
    makeLongShortContract(providerOrSigner)->LongShort.marketSideValueInPaymentToken(~marketIndex)

  let marketSideValue = (providerOrSigner, marketIndex, isLong) =>
    makeLongShortContract(providerOrSigner)
    ->LongShort.marketSideValueInPaymentToken(~marketIndex)
    ->thenResolve(marketSideValue =>
      switch isLong {
      | true => marketSideValue.long
      | false => marketSideValue.short
      }
    )

  let marketSideUnconfirmedDeposits = (providerOrSigner, marketIndex, isLong) =>
    makeLongShortContract(providerOrSigner)->LongShort.batched_amountPaymentToken_deposit(
      ~marketIndex,
      ~isLong,
    )

  let marketSideUnconfirmedRedeems = (providerOrSigner, marketIndex, isLong) =>
    makeLongShortContract(providerOrSigner)->LongShort.batched_amountSyntheticToken_redeem(
      ~marketIndex,
      ~isLong,
    )

  let marketSideUnconfirmedShifts = (providerOrSigner, marketIndex, isShiftFromLong) =>
    makeLongShortContract(
      providerOrSigner,
    )->LongShort.batched_amountSyntheticToken_toShiftAwayFrom_marketSide(
      ~marketIndex,
      ~isLong=isShiftFromLong,
    )

  let getSyntheticTokenPrice = (providerOrSigner, marketIndex, isLong) =>
    all2((
      marketSideValue(providerOrSigner, marketIndex, isLong),
      syntheticTokenTotalSupply(providerOrSigner, marketIndex, isLong),
    ))->thenResolve(((value, total)) =>
      value->BigNumber.mul(CONSTANTS.tenToThe18)->BigNumber.div(total)
    )

  let getExposure = (providerOrSigner, marketIndex, isLong) =>
    marketSideValues(providerOrSigner, marketIndex)->thenResolve(values => {
      let numerator = values.long->min(values.short)->mul(CONSTANTS.tenToThe18)
      switch isLong {
      | true => numerator->div(values.long)
      | false => numerator->div(values.short)
      }
    })

  let getUnconfirmedExposure = (providerOrSigner, marketIndex, isLong) =>
    all([
      getSyntheticTokenPrice(providerOrSigner, marketIndex, true),
      getSyntheticTokenPrice(providerOrSigner, marketIndex, false),
      marketSideUnconfirmedRedeems(providerOrSigner, marketIndex, true),
      marketSideUnconfirmedRedeems(providerOrSigner, marketIndex, false),
      marketSideUnconfirmedShifts(providerOrSigner, marketIndex, true),
      marketSideUnconfirmedShifts(providerOrSigner, marketIndex, false),
      marketSideUnconfirmedDeposits(providerOrSigner, marketIndex, true),
      marketSideUnconfirmedDeposits(providerOrSigner, marketIndex, false),
      marketSideValue(providerOrSigner, marketIndex, true),
      marketSideValue(providerOrSigner, marketIndex, false),
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

  let newFloatMarketSide = (p: providerOrSigner, marketIndex, isLong) => {
    {
      getSyntheticTokenPrice: _ => getSyntheticTokenPrice(p, marketIndex, isLong),
      getExposure: _ => getExposure(p, marketIndex, isLong),
      getUnconfirmedExposure: _ => getUnconfirmedExposure(p, marketIndex, isLong),
    }
  }
}
