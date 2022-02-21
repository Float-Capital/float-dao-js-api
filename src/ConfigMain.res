open Ethers

let chainId = 137

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

@module("./config/configuration.js") external polygonConfig: configType = "polygon"
