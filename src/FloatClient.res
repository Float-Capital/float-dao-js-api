open FloatEthers

type client = {
  getChainWithProvider: providerType => FloatChain.chainWithProvider,
  getChainWithWallet: walletType => FloatChain.chainWithWallet,
  getChain: int => FloatChain.chainWithProvider,
  // TODO add getChains method that returns all the chains that float is deployed on
}

let make = _ => {
  getChainWithProvider: FloatChain.makeWithProvider,
  getChainWithWallet: FloatChain.makeWithWallet,
  getChain: i => i->FloatChain.makeWithDefaultProvider,
}
