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
  //let marketSideConnected =
  //  providerUrl
  //  ->Provider.JsonRpcProvider.make(~chainId=137)
  //  ->connectToNewWallet(~mnemonic)
  //  ->MarketSide.makeWithWallet(BigNumber.fromInt(1), false)

  let marketSide =
    providerUrl
    ->Provider.JsonRpcProvider.make(~chainId=137)
    //->connectToNewWallet(~mnemonic)
    ->MarketSide.makeWithProvider(BigNumber.fromInt(1), false)

  let maxFeePerGas = BigNumber.fromInt(62)->BigNumber.mul(CONSTANTS.oneGweiInWei)
  let maxPriorityFeePerGas = BigNumber.fromInt(34)->BigNumber.mul(CONSTANTS.oneGweiInWei)
  let gasLimit = BigNumber.fromInt(1000000)

  let txOptions: Contracts.txOptions = {
    maxFeePerGas: maxFeePerGas->BigNumber.toString,
    maxPriorityFeePerGas: maxPriorityFeePerGas->BigNumber.toString,
    gasLimit: gasLimit->BigNumber.toString,
  }

  //marketSide.getUnconfirmedExposure()
  //->Promise.thenResolve(a => a->BigNumber.toString->Js.log)
  //->ignore
  //marketSide.getExposure()->Promise.thenResolve(a => a->BigNumber.toString->Js.log)->ignore
  //marketSide.getPositions("0x380d3d688fd65ef6858f0e094a1a9bba03ad76a3"->Utils.getAddressUnsafe)
  //->Promise.thenResolve(a => a.synthToken->BigNumber.toString->Js.log)
  //->ignore

  marketSide.getFundingRateApr()->Promise.thenResolve(a => a->Js.log)->ignore
  //marketSide.getValue()->Promise.thenResolve(a => a->BigNumber.toString->Js.log)->ignore

  //let marketSideConnected =
  //  providerUrl
  //  ->Provider.JsonRpcProvider.make(~chainId=137)
  //  ->connectToNewWallet(~mnemonic)
  //  ->marketSide.connect

  //marketSideConnected.shift(
  //  BigNumber.fromInt(1)->BigNumber.mul(CONSTANTS.tenToThe18), //->BigNumber.div(CONSTANTS.tenToThe2),
  //  txOptions,
  //)->Promise.thenResolve(tx => tx.hash->Js.log)->ignore

  //providerUrl
  //->Provider.JsonRpcProvider.make(~chainId)
  //->connectToNewWallet(~mnemonic)
  //->Wallet.getBalance
  //->Promise.thenResolve(balance => {
  //  Js.log2("Account balance:", balance->Utils.formatEther)
  //})
  //->ignore

  let market =
    providerUrl
    ->Provider.JsonRpcProvider.make(~chainId=137)
    //->connectToNewWallet(~mnemonic)
    ->Market.makeWithProvider(1)

  //market.getFundingRateMultiplier()->Promise.thenResolve(a => a->Js.log)->ignore
}

let _ = run()
