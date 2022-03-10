open Contracts
open Ethers
open ConfigMain
open Promise

let {min, div, mul, add} = module(Ethers.BigNumber)

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
      makeLongShortContract(providerOrSigner)
      ->LongShort.marketSideValueInPaymentToken(~marketIndex)

  let marketSideValue = (providerOrSigner, marketIndex, isLong) =>
    makeLongShortContract(providerOrSigner)
    ->LongShort.marketSideValueInPaymentToken(~marketIndex)
    ->thenResolve(marketSideValue =>
      switch isLong {
      | true => marketSideValue.long
      | false => marketSideValue.short
      }
    )

  let marketSideUnconfirmedValues = (providerOrSigner, marketIndex, isLong) =>
      makeLongShortContract(providerOrSigner)
      ->LongShort.batched_amountPaymentToken_deposit(~marketIndex, ~isLong)

  let getSyntheticTokenPrice = (providerOrSigner, marketIndex, isLong) =>
    all2((
      marketSideValue(providerOrSigner, marketIndex, isLong),
      syntheticTokenTotalSupply(providerOrSigner, marketIndex, isLong),
    ))->thenResolve(((value, total)) =>
      value->BigNumber.mul(CONSTANTS.tenToThe18)->BigNumber.div(total)
    )

  let getExposure  = (providerOrSigner, marketIndex, isLong) =>
      marketSideValues(providerOrSigner, marketIndex)
      ->thenResolve(values => {
        let numerator = values.long->min(values.short)->mul(CONSTANTS.tenToThe18)
        switch isLong {
            | true => numerator->div(values.long)
            | false => numerator->div(values.short)
        }
        }
      )

  let getUnconfirmedExposure = (providerOrSigner, marketIndex, isLong) =>
      all3((
        marketSideValues(providerOrSigner, marketIndex),
        marketSideUnconfirmedValues(providerOrSigner, marketIndex, true),
        marketSideUnconfirmedValues(providerOrSigner, marketIndex, false),
      ))->thenResolve(((values, unconfirmedLong, unconfirmedShort)) => {
        let valueLong = values.long->add(unconfirmedLong)
        let valueShort = values.short->add(unconfirmedShort)
        let numerator = valueLong->min(valueShort)->mul(CONSTANTS.tenToThe18)
        switch isLong {
            | true => numerator->div(valueLong)
            | false => numerator->div(valueShort)
        }
        }
      )

  let newFloatMarketSide = (p: providerOrSigner, marketIndex, isLong) => {
    {
      getSyntheticTokenPrice: _ => getSyntheticTokenPrice(p, marketIndex, isLong),
      getExposure: _ => getExposure(p, marketIndex, isLong),
      getUnconfirmedExposure: _ => getUnconfirmedExposure(p, marketIndex, isLong),
    }
  }
}
