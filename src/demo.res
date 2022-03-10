open Ethers

@val external process: 'a = "process"
let env = process["env"]

@module("../secretsManager.js") external mnemonic: string = "mnemonic"
@module("../secretsManager.js") external providerUrl: string = "providerUrl"

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
  let float =
    providerUrl
    ->Providers.JsonRpcProvider.make(~chainId=137)
    ->connectToNewWallet(~mnemonic)
    ->getSigner
    ->MarketSide.MarketSide.newFloatMarketSide(BigNumber.fromInt(1), false)

  float.getUnconfirmedExposure()->Promise.thenResolve(a => a->BigNumber.toString->Js.log)->ignore
  float.getExposure()->Promise.thenResolve(a => a->BigNumber.toString->Js.log)->ignore

  //providerUrl
  //->Providers.JsonRpcProvider.make(~chainId)
  //->connectToNewWallet(~mnemonic)
  //->Wallet.getBalance
  //->Promise.thenResolve(balance => {
  //  Js.log2("Account balance:", balance->Utils.formatEther)
  //})
  //->ignore
}

let _ = run()
