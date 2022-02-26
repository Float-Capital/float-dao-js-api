open Contracts
open Ethers
open ConfigMain
open Promise

module MarketSide = {
  type a = {getSyntheticTokenPrice: unit => Promise.t<Ethers.BigNumber.t>}

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

  let marketSideValue = (providerOrSigner, marketIndex, isLong) =>
    makeLongShortContract(providerOrSigner)
    ->LongShort.marketSideValueInPaymentToken(~marketIndex)
    ->thenResolve(marketSideValue =>
      switch isLong {
      | true => marketSideValue.long
      | false => marketSideValue.short
      }
    )

  let getSyntheticTokenPrice = (providerOrSigner, marketIndex, isLong) =>
    all2((
      marketSideValue(providerOrSigner, marketIndex, isLong),
      syntheticTokenTotalSupply(providerOrSigner, marketIndex, isLong),
    ))->thenResolve(((value, total)) =>
      value->BigNumber.mul(CONSTANTS.tenToThe18)->BigNumber.div(total)
    )

  let newFloatMarketSide = (p: providerOrSigner, marketIndex, isLong) => {
    {
      getSyntheticTokenPrice: _ => getSyntheticTokenPrice(p, marketIndex, isLong),
    }
  }
}
