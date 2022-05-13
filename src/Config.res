open Ethers
open FloatConfig

//let chainId = 137
//
//type market = {
//  index: int,
//  leverage: int,
//  longTokenAddress: string,
//  shortTokenAddress: string,
//}
//
//type gas = {gasPrice: ethersBigNumber, gasLimit: ethersBigNumber}
//
//type configType = {
//  longShortContractAddress: string,
//  stakerContractAddress: string,
//  daiAddress: string,
//  pairAddress: string,
//  uniswapV2RouterAddress: string,
//  markets: array<market>,
//  defaultOptions: gas,
//}

//@module("./config/configuration.js") external polygonConfig: configType = "polygon"

// TODO fix these so that they actually fix the correct config and don't just return ava one

let getChainConfig = (pw: providerOrWallet) =>
  switch pw {
  | ProviderWrap(p) => p
  | WalletWrap(w) => w.provider
  }
  ->Provider.getNetwork
  ->Promise.thenResolve(network => {
    let a = network.chainId
    avalanche
  })

let getChainConfigUsingId = chainId => avalanche

let makeDefaultProvider = c => c.rpcEndopint->Provider.JsonRpcProvider.make(~chainId=c.networkId)
