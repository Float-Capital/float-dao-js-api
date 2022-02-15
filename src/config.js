let ethers = require("ethers");

module.exports = {
  polygon: {
    longShortAddress: "0x168a5d1217AEcd258b03018d5bF1A1677A07b733",
    daiAddress: "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063",
    pairAddress: "",
    uniswapV2RouterAddress: "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506", // sushiswap router
    markets: {
      threeth: {
        index: 2,
        leverage: 3,
        longTokenAddress: "0x5bF9dFB1B27c28e5a1D8e5c5385A1A353eC9D118",
        shortTokenAddress: "0x97B0Ba4a8Ba02B8d002C156a7BEdBF5264CC0f7A",
      },
    },
    defaultOptions: { gasPrice: 7000000000, gasLimit: 1000000 },
  },
  avalanche: {
    longShortAddress: "0x0db3c59c187ecfa36a9C9f6CFa3664D06c2B5556",
    daiAddress: "0xd586E7F844cEa2F87f50152665BCbc2C279D8d70",
    pairAddress: "0x6e84a6216eA6dACC71eE8E6b0a5B7322EEbC0fDd", // JOE token
    uniswapV2RouterAddress: "0x60aE616a2155Ee3d9A68541Ba4544862310933d4", // Trader joe router
    markets: {
      joe: {
        index: 2,
        leverage: 2,
        longTokenAddress: "0x6A621D256CFEDa1c10ab0Cbd1Ff8d5310b35e4d3",
        shortTokenAddress: "0x1dCAA44bEA82bd135C51b158E5E702e3C1843951",
      },
    },
    defaultOptions: { gasPrice: 7000000000, gasLimit: 1000000 },
  },
  mumbai: {
    longShortAddress: "0x4E95db55dbF56ebfebB58090b968b118491800A8",
    daiAddress: "0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F",
    pairAddress: "0x16daf830354eb3e496b610dfbe3562f84cd5b50e",
    uniswapV2RouterAddress: "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506", // sushiswap router
    markets: {
      threeth: {
        index: 1,
        leverage: 3,
        longTokenAddress: "0xde110beEE58e2Acd21E51158FF904E3BF5122466",
        shortTokenAddress: "0x56692a61f16FddDAe7a8466143AabE34E7c59D49",
      },
    },
    defaultOptions: {
      gasPrice: 2000000000,
      gasLimit: 800000,
      // maxFeePerGas: 2000000000,
      // maxPriorityFeePerGas: 2000000000,
    },
  },
};
