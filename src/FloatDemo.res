open FloatEthers

@val external process: 'a = "process"
let env = process["env"]

@module("../secretsManager.js") external mnemonic: string = "mnemonic"
@module("../secretsManager.js") external providerUrlOther: string = "providerUrl"

let {oneGweiInWei} = module(FloatEthers.BigNumber)

let connectToNewWallet = (provider, ~mnemonic) =>
  Wallet.fromMnemonicWithPath(~mnemonic, ~path=`m/44'/60'/0'/0/0`)->Wallet.connect(provider)

let providerUrl = FloatConfig.avalanche.rpcEndopint
let chainId = FloatConfig.avalanche.networkId

let provider = providerUrl->Provider.JsonRpcProvider.make(~chainId)
let wallet = providerUrl->Provider.JsonRpcProvider.make(~chainId)->connectToNewWallet(~mnemonic)

let maxFeePerGas = BigNumber.fromInt(62)->BigNumber.mul(oneGweiInWei)
let maxPriorityFeePerGas = BigNumber.fromInt(34)->BigNumber.mul(oneGweiInWei)
let gasLimit = BigNumber.fromInt(1000000)

let txOptions: FloatContracts.txOptions = {
  maxFeePerGas: maxFeePerGas->BigNumber.toString,
  maxPriorityFeePerGas: maxPriorityFeePerGas->BigNumber.toString,
  gasLimit: gasLimit->BigNumber.toString,
}

let run = () => {
  let floatClient = FloatClient.make()

  let chain = floatClient.getChain(chainId)
  chain.contracts
  ->Promise.thenResolve(c => "LongShort address:"->Js.log2(c.longShort.address))
  ->ignore

  let marketIndex = 1
  let market = marketIndex->chain.getMarket

  market.getFundingRateMultiplier()
  ->Promise.thenResolve(a =>
    "Funding rate multiplier for market "
    ->Js.String2.concat(marketIndex->Js.Int.toString)
    ->Js.String2.concat(":")
    ->Js.log2(a)
  )
  ->ignore

  market.getLeverage()
  ->Promise.thenResolve(m =>
    "Leverage for market "
    ->Js.String2.concat(marketIndex->Js.Int.toString)
    ->Js.String2.concat(":")
    ->Js.log2(m)
  )
  ->ignore

  let isLong = false
  let sideName = switch isLong {
  | true => "long"
  | false => "short"
  }

  let marketSide = isLong->market.getSide

  marketSide.getFundingRateApr()
  ->Promise.thenResolve(a =>
    "Funding rate APR for marketSide "
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a)
  )
  ->ignore

  marketSide.getExposure()
  ->Promise.thenResolve(a =>
    "Exposure of marketSide"
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a->BigNumber.toString)
  )
  ->ignore

  marketSide.getUnconfirmedExposure()
  ->Promise.thenResolve(a =>
    "Unconfirmed exposure of marketSide"
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a->BigNumber.toString)
  )
  ->ignore

  let address = "0x380d3d688fd65ef6858f0e094a1a9bba03ad76a3"
  marketSide.getPositions(address->Utils.getAddressUnsafe)
  ->Promise.thenResolve(a =>
    "Synth token amount for 0x38.. in marketSide"
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a.synthToken->BigNumber.toString)
  )
  ->ignore

  //let marketSideConnected =
  //  providerUrl
  //  ->Provider.JsonRpcProvider.make(~chainId=137)
  //  ->connectToNewWallet(~mnemonic)
  //  ->MarketSide.makeWithWallet(BigNumber.fromInt(1), false)

  //marketSideConnected.shift(
  //  BigNumber.fromInt(1)->BigNumber.mul(CONSTANTS.tenToThe18), //->BigNumber.div(CONSTANTS.tenToThe2),
  //  txOptions,
  //)->Promise.thenResolve(tx => tx.hash->Js.log)->ignore

  //wallet
  //->Wallet.getBalance
  //->Promise.thenResolve(balance => {
  //  Js.log2("Account balance:", balance->Utils.formatEther)
  //})
  //->ignore

  //let chain = 43114->Chain.makeWithDefaultProvider

  //chain.getMarket(1).getFundingRateMultiplier()->Promise.thenResolve(m => m->Js.log)->ignore

  //connectedChain.getMarket(1)

  //let chainWithProviderOrWallet = Chain.make(wallet->wrapWallet)

  //switch chainWithProviderOrWallet {
  //    | ChainPWrap(c) => c.getMarket(1).getFundingRateMultiplier()->Promise.thenResolve(m => m->Js.log)->ignore
  //    | ChainWWrap(c) => c.getMarket(1).getLeverage()->Promise.thenResolve(m => m->Js.log)->ignore
  //}
}

let runDemo = _ => {
  let marketIndex = 1
  let isLong = true
  let sideName = switch isLong {
  | true => "long"
  | false => "short"
  }

  let marketSide = FloatMarketSide.WithProvider.makeWrap(provider, marketIndex, isLong)

  marketSide
  ->FloatMarketSide.getValue
  ->Promise.thenResolve(a =>
    "Value of marketSide "
    ->Js.String2.concat(sideName)
    ->Js.String2.concat(":")
    ->Js.log2(a->BigNumber.toString)
  )
  ->ignore
}

let _ = run()
