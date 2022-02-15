open Ethers
open Contracts

@val external process: 'a = "process"
let env = process["env"]

@module("../secretsManager.js") external mnemonic: string = "mnemonic"
@module("../secretsManager.js") external providerUrl: string = "providerUrl"

type market = {
  index: int,
  leverage: int,
  longTokenAddress: string,
  shortTokenAddress: string,
}

type gas = { gasPrice: ethersBigNumber, gasLimit: ethersBigNumber}

type configType = {
  longShortContractAddress: string,
  daiAddress: string,
  pairAddress: string,
  uniswapV2RouterAddress: string,
  markets: array<market>,
  defaultOptions: gas,
}

@module("./config.js") external polygonConfig: configType = "polygon"

//type s = {
//  providerUrl: string,
//  mnemonic: string,
//}
//
//let getSecrets = {
//  switch (env["PROVIDER_URL"], env["MNEMONIC"]) {
//  | (Some(providerUrl), Some(mnemonic)) => {
//      providerUrl: providerUrl,
//      mnemonic: mnemonic,
//    }
//  | _ =>
//    let _ = Js.Exn.raiseError("`PROVIDER_URL` & `MNEMONIC` must be specified in your environment")
//    {
//      providerUrl: "",
//      mnemonic: "mnemonic not configured",
//    }
//  }
//}
// 
//let {providerUrl, mnemonic} = getSecrets

let connectToNewWallet = (provider, ~mnemonic) =>
  Wallet.fromMnemonicWithPath(~mnemonic, ~path=`m/44'/60'/0'/0/0`)->Wallet.connect(provider)

let run = () => {
  let chainId = 137

  providerUrl
  ->Providers.JsonRpcProvider.make(~chainId)
  ->connectToNewWallet(~mnemonic)
  ->Wallet.getBalance
  ->Promise.thenResolve(balance => {
    Js.log2("Account balance:", balance->Utils.formatEther)
  })
  ->ignore

  //let longShortContract =
  //  LongShort.make(
  //    ~address=polygonConfig.longShortContractAddress->Utils.getAddressUnsafe,
  //    ~providerOrSigner=defaultWallet.contents->getSigner,
  //  )
}

let _ = run()
