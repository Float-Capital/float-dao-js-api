open Ethers

type client = {
  getChainWithProvider: providerType => Chain.chainWithProvider,
  getChainWithWallet: walletType => Chain.chainWithWallet,
  getChain: int => Chain.chainWithProvider,
  // TODO add getChains method that returns all the chains that float is deployed on
}

let make = _ => {
  getChainWithProvider: Chain.makeWithProvider,
  getChainWithWallet: Chain.makeWithWallet,
  getChain: i => i->Chain.makeWithDefaultProvider,
}
