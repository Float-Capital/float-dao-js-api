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

// TODO remember to add an approval function for longshort to spend DAI

let connectToNewWallet = (provider, ~mnemonic) =>
  Wallet.fromMnemonicWithPath(~mnemonic, ~path=`m/44'/60'/0'/0/0`)->Wallet.connect(provider)

let run = () => {
  let float =
    providerUrl
    ->Providers.JsonRpcProvider.make(~chainId=137)
    ->connectToNewWallet(~mnemonic)
    ->getSigner
    ->MarketSide.MarketSide.newFloatMarketSide(BigNumber.fromInt(1), true)

  let maxFeePerGas = BigNumber.fromInt(62)->BigNumber.mul(CONSTANTS.oneGweiInWei)
  let maxPriorityFeePerGas = BigNumber.fromInt(34)->BigNumber.mul(CONSTANTS.oneGweiInWei)
  let gasLimit = BigNumber.fromInt(600000)

  let txOptions: Contracts.txOptions = {
    maxFeePerGas: maxFeePerGas->BigNumber.toString,
    maxPriorityFeePerGas: maxPriorityFeePerGas->BigNumber.toString,
    gasLimit: gasLimit->BigNumber.toString,
  }

  //float.getUnconfirmedExposure()->Promise.thenResolve(a => a->BigNumber.toString->Js.log)->ignore
  //float.getExposure()->Promise.thenResolve(a => a->BigNumber.toString->Js.log)->ignore
  //float.getStakedPositions("0x5b7a3a14D0488eaC9c1A1f943A80ECD983711797"->Utils.getAddressUnsafe)
  //->Promise.thenResolve(a => a.paymentToken->BigNumber.toString->Js.log)

  // TODO is just the shift that is not working
  float.shift(BigNumber.fromInt(22)->BigNumber.mul(CONSTANTS.tenToThe18)->BigNumber.div(CONSTANTS.tenToThe2), txOptions)
  ->Promise.thenResolve(tx => tx.hash->Js.log)

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
