open Contracts
open Ethers
open Promise
open Config

type chainWithWallet = {
  contracts: Promise.t<FloatConfig.contracts>,
  updateSystemState: (array<BigNumber.t>, txOptions) => Promise.t<Ethers.txSubmitted>,
  getMarket: int => Market.marketWithWallet,
}

type chainWithProvider = {
  contracts: Promise.t<FloatConfig.contracts>,
  getMarket: int => Market.marketWithProvider,
  connect: walletType => chainWithWallet,
}

let makeLongShortContract = (
  p: providerOrWallet,
  c: FloatConfig.chainConfigShape,
): Ethers.Contract.t =>
  LongShort.make(
    ~address=c.contracts.longShort.address->Utils.getAddressUnsafe,
    ~providerOrWallet=p,
  )

let updateSystemStateMulti = (
  w: walletType,
  c: FloatConfig.chainConfigShape,
  marketIndexes: array<BigNumber.t>,
) => w->wrapWallet->makeLongShortContract(c)->LongShort.updateSystemStateMulti(~marketIndexes)

// TODO add getLongShortmplentationAddress function that fetches the current implentation address

// TODO add getPositions that fetches for all markets

// TODO add settleOutstandingActions that settles for all markets

let makeWithWallet = (w: walletType): chainWithWallet => {
  contracts: w->wrapWallet->getChainConfig->thenResolve(c => c.contracts),
  updateSystemState: (marketIndexes, txOptions) =>
    w
    ->wrapWallet
    ->getChainConfig
    ->then(c => updateSystemStateMulti(w, c, marketIndexes, txOptions)),
  getMarket: Market.makeWithWallet(w),
}

let makeWithProvider = (p: providerType): chainWithProvider => {
  contracts: p->wrapProvider->getChainConfig->thenResolve(c => c.contracts),
  getMarket: Market.makeWithProvider(p),
  connect: w => makeWithWallet(w),
}

let makeWithDefaultProvider = (chainId: int) => {
  contracts: chainId
  ->getChainConfigUsingId
  ->makeDefaultProvider
  ->wrapProvider
  ->getChainConfig
  ->thenResolve(c => c.contracts),
  getMarket: Market.makeWithProvider(chainId->getChainConfigUsingId->makeDefaultProvider),
  connect: w => makeWithWallet(w),
}
