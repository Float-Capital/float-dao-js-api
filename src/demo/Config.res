type s = {
  providerUrls: array<string>,
  mnemonic: string,
  apiKey: string,
}
type marketConfig = {
  oracles: option<array<Ethers.ethAddress>>,
  heartbeat: option<int>,
  useKeeper: bool,
}

type oraclesToWatch = {linkedMarketIds: array<int>}

type gasPriceDeterminationType = [#rpc | #gasstation | #etherscan]
type gasPrice = {
  fetchMethod: gasPriceDeterminationType,
  gasPriceStationUrl: option<string>,
  defaultGasPriceInGwei: option<float>,
  defaultMaxPriorityFeeInGwei: option<float>,
  minimumMaxPriorityFee: option<int>,
  apiUrl: option<string>,
}
type c = {
  longShortContractAddress: Ethers.ethAddress,
  keeperContractAddress: Ethers.ethAddress,
  gasPrice: gasPrice,
  chainId: option<int>,
  marketSettings: Js.Dict.t<marketConfig>,
  networkName: string,
  networkExplorer: string,
}

@val external process: 'a = "process"
let env = process["env"]

let getSecrets = {
  switch (env["PROVIDER_URL"], env["MNEMONIC"], env["ETHERSCAN_API_KEY"]) {
  | (Some(providerUrl), Some(mnemonic), Some(apiKey)) => {
      providerUrls: [providerUrl],
      mnemonic: mnemonic,
      apiKey: apiKey,
    }
  | _ =>
    let _ = Js.Exn.raiseError(
      "`PROVIDER_URL`,`ETHERSCAN_API_KEY` & `MNEMONIC` must be specified in your environment",
    )
    {
      providerUrls: [""],
      mnemonic: "mnemonic not configured",
      apiKey: "",
    }
  }
}
let secrets = getSecrets

@val external getConfig: string => c = "require"

let config = getConfig(process["env"]["CONFIG_PATH"]->Belt.Option.getWithDefault("../config.js"))

let defaultGasPriceInGwei = config.gasPrice.defaultGasPriceInGwei->Belt.Option.getWithDefault(15.0)
let defaultMaxPriorityFeeInGwei =
  config.gasPrice.defaultMaxPriorityFeeInGwei->Belt.Option.getWithDefault(35.0)
type logLevels = [#error | #info | #other]
type backupModeConfig = {backupTimeDelayInSeconds: int}
type operationModes = MainNode | BackupNode(backupModeConfig)
let webhookUrl =
  process["env"]["DISCORD_WEBHOOK_URI"]->Belt.Option.getWithDefault(
    "https://discord.com/api/webhooks/899598787159412766/LKQb25fFAZyTGquWTS__D8Ego1tWADebIjp1OWlywmCij3tXKFGsYaZI_d2S0sLUFJTR",
  )
let debugWebhookUrl =
  process["env"]["DEBUG_DISCORD_WEBHOOK_URI"]->Belt.Option.getWithDefault(
    "https://discord.com/api/webhooks/907272357788397620/7L0aS-wMI6c-gmfyRMo9Fy4Ps18GOaA2lJkrsKmVqZXtvia9o_qIyXvlhD8EcqMGvagz",
  )
let minGasPrice =
  process["env"]["MIN_GAS_PRICE"]->Belt.Option.mapWithDefault(
    Ethers.BigNumber.fromInt(15),
    gasPriceString => Ethers.BigNumber.fromUnsafe(gasPriceString),
  )
let minimumMaxPriorityFee =
  process["env"]["MIN_MAX_PRIORITY_FEE"]->Belt.Option.mapWithDefault(
    Ethers.BigNumber.fromInt(2),
    gasPriceString =>
      Ethers.BigNumber.fromUnsafe(gasPriceString)->Ethers.BigNumber.mul(CONSTANTS.oneGweiInWei),
  )
let maxFeePerGas =
  process["env"]["MAX_FEE_PER_GAS"]->Belt.Option.map(gasPriceString =>
    Ethers.BigNumber.fromUnsafe(gasPriceString)->Ethers.BigNumber.mul(CONSTANTS.oneGweiInWei)
  )
let maxPayableGasFee =
  process["env"]["MAX_PAYABLE_GAS_FEE"]->Belt.Option.mapWithDefault(
    Ethers.BigNumber.fromInt(10000)->Ethers.BigNumber.mul(
      CONSTANTS.oneGweiInWei,
    ) /* default max of 10000 gwei */,
    gasPriceString =>
      Ethers.BigNumber.fromUnsafe(gasPriceString)->Ethers.BigNumber.mul(CONSTANTS.oneGweiInWei),
  )
let maxPriorityFeeIncrement =
  process["env"]["MAX_PRIORITY_FEE_INCREMENT"]->Belt.Option.mapWithDefault(
    Ethers.BigNumber.fromInt(10)->Ethers.BigNumber.mul(
      CONSTANTS.oneGweiInWei,
    ) /* default max of 10 gwei */,
    gasPriceString =>
      Ethers.BigNumber.fromUnsafe(gasPriceString)->Ethers.BigNumber.mul(CONSTANTS.oneGweiInWei),
  )
let logLevel = process["env"]["MSG_LOG_LEVEL"]->Belt.Option.getWithDefault(#info)
let botMode = process["env"]["BACKUP_TIME_DELAY_SECONDS"]->Belt.Option.mapWithDefault(
  MainNode,
  backupTimeDelayInSecondsStr => {
    let backupTimeDelayInSeconds =
      backupTimeDelayInSecondsStr->Belt.Int.fromString->Belt.Option.getWithDefault(45)

    BackupNode({
      backupTimeDelayInSeconds: backupTimeDelayInSeconds,
    })
  },
)

let botModeString = switch botMode {
| MainNode => "main"
| BackupNode(_backupNodeConfig) => "backup"
}
