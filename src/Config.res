open Ethers
open FloatConfig

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
