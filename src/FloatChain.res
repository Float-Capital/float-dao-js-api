open FloatContracts
open FloatEthers
open Promise
open FloatUtil

type chainWithWallet = {
  // TODO possibly change this to getContracts to make it clear it's a promise
  contracts: Promise.t<FloatConfig.contracts>,
  updateSystemState: (array<BigNumber.t>, txOptions) => Promise.t<FloatEthers.txSubmitted>,
  getMarket: int => FloatMarket.marketWithWallet,
}

type chainWithProvider = {
  contracts: Promise.t<FloatConfig.contracts>,
  getMarket: int => FloatMarket.withProvider,
  connect: walletType => chainWithWallet,
}

type chainProviderOrWallet =
  | ChainPWrap(chainWithProvider)
  | ChainWWrap(chainWithWallet)

let wrapChainWithProvider: chainWithProvider => chainProviderOrWallet = p => ChainPWrap(p)
let wrapChainWithWallet: chainWithWallet => chainProviderOrWallet = p => ChainWWrap(p)

let makeLongShortContract = (
  p: providerOrWallet,
  c: FloatConfig.chainConfigShape,
): FloatEthers.Contract.t =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let updateSystemStateMulti = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndexes: array<BigNumber.t>,
) => w->wrapWallet->makeLongShortContract(c)->LongShort.updateSystemStateMulti(~marketIndexes)

// TODO add getLongShortImplementationAddress function that fetches the current implentation address

// TODO add getPositions that fetches for all markets

// TODO add settleOutstandingActions that settles for all markets

let makeWithWallet = (w: walletType): chainWithWallet => {
  contracts: w->wrapWallet->getChainConfig->thenResolve(c => c.contracts),
  updateSystemState: (marketIndexes, txOptions) =>
    w
    ->wrapWallet
    ->getChainConfig
    ->then(c => updateSystemStateMulti(w, c, marketIndexes, txOptions)),
  getMarket: FloatMarket.makeWithWallet(w),
}

let makeWithProvider = (p: providerType): chainWithProvider => {
  contracts: p->wrapProvider->getChainConfig->thenResolve(c => c.contracts),
  getMarket: FloatMarket.WithProvider.make(p),
  connect: w => makeWithWallet(w),
}

let makeWithDefaultProvider = (chainId: int) => {
  contracts: chainId
  ->getChainConfigUsingId
  ->makeDefaultProvider
  ->wrapProvider
  ->getChainConfig
  ->thenResolve(c => c.contracts),
  getMarket: FloatMarket.WithProvider.make(chainId->getChainConfigUsingId->makeDefaultProvider),
  connect: w => makeWithWallet(w),
}

// This is just here as a test, not actually used but maybe we can use it in the future
let make = (pw: providerOrWallet): chainProviderOrWallet => {
  switch pw {
  | P(p) => makeWithProvider(p)->wrapChainWithProvider
  | W(w) => makeWithWallet(w)->wrapChainWithWallet
  }
}
