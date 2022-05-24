// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Ethers = require("ethers");
var FloatChain = require("./FloatChain.js");
var FloatConfig = require("@float-dao/config/src/FloatConfig.js");
var FloatEthers = require("./FloatEthers.js");
var FloatMarket = require("./FloatMarket.js");
var FloatMarketSide = require("./FloatMarketSide.js");
var SecretsManagerJs = require("../secretsManager.js");

var env = process.env;

var mnemonic = SecretsManagerJs.mnemonic;

var providerUrlOther = SecretsManagerJs.providerUrl;

var oneGweiInWei = FloatEthers.BigNumber.oneGweiInWei;

function fromInt(prim) {
  return Ethers.BigNumber.from(prim);
}

function connectToNewWallet(provider, mnemonic) {
  return new (Ethers.Wallet.fromMnemonic)(mnemonic, "m/44'/60'/0'/0/0").connect(provider);
}

var providerUrl = FloatConfig.avalanche.rpcEndopint;

var chainId = FloatConfig.avalanche.networkId;

var provider = new (Ethers.providers.JsonRpcProvider)(providerUrl, chainId);

var wallet = connectToNewWallet(new (Ethers.providers.JsonRpcProvider)(providerUrl, chainId), mnemonic);

var maxFeePerGas = Ethers.BigNumber.from(62).mul(oneGweiInWei);

var maxPriorityFeePerGas = Ethers.BigNumber.from(34).mul(oneGweiInWei);

var gasLimit = Ethers.BigNumber.from(1000000);

var txOptions_maxFeePerGas = maxFeePerGas.toString();

var txOptions_maxPriorityFeePerGas = maxPriorityFeePerGas.toString();

var txOptions_gasLimit = gasLimit.toString();

var txOptions = {
  maxFeePerGas: txOptions_maxFeePerGas,
  maxPriorityFeePerGas: txOptions_maxPriorityFeePerGas,
  gasLimit: txOptions_gasLimit
};

function demoReadyOnly(param) {
  wallet.getBalance().then(function (balance) {
        console.log("Account balance:", FloatEthers.Utils.formatEther(balance));
        
      });
  var sideName = "long";
  var chain = FloatChain.WithProvider.makeDefault(chainId);
  FloatChain.contracts(chain).then(function (c) {
        console.log("LongShort address:", c.longShort.address);
        
      });
  var market = FloatMarket.WithProvider.make(provider, 1);
  FloatMarket.fundingRateMultiplier(market).then(function (a) {
        console.log("Funding rate multiplier for market ".concat((1).toString()).concat(":"), a);
        
      });
  FloatMarket.leverage(market).then(function (m) {
        console.log("Leverage for market ".concat((1).toString()).concat(":"), m);
        
      });
  var marketSide = FloatMarketSide.makeUsingMarket(market, true);
  FloatMarketSide.poolValue(marketSide).then(function (a) {
        console.log("Value of marketSide ".concat(sideName).concat(":"), a.toString());
        
      });
  FloatMarketSide.fundingRateApr(marketSide).then(function (a) {
        console.log("Funding rate APR for marketSide ".concat(sideName).concat(":"), a);
        
      });
  FloatMarketSide.exposure(marketSide).then(function (a) {
        console.log("Exposure of marketSide".concat(sideName).concat(":"), a.toString());
        
      });
  FloatMarketSide.unconfirmedExposure(marketSide).then(function (a) {
        console.log("Unconfirmed exposure of marketSide".concat(sideName).concat(":"), a.toString());
        
      });
  FloatMarketSide.positions(marketSide, "0x380d3d688fd65ef6858f0e094a1a9bba03ad76a3", undefined).then(function (a) {
        console.log("Synth token amount for 0x38.. in marketSide".concat(sideName).concat(":"), a.syntheticToken.toString());
        
      });
  
}

function demoWrite(param) {
  FloatChain.WithWallet.make(wallet);
  var market = FloatMarket.WithWallet.makeUnwrapped(wallet, 1);
  FloatMarket.settleOutstandingActions(market, undefined, txOptions).then(function (tx) {
        console.log(tx.hash);
        
      });
  
}

demoWrite(undefined);

exports.env = env;
exports.mnemonic = mnemonic;
exports.providerUrlOther = providerUrlOther;
exports.oneGweiInWei = oneGweiInWei;
exports.fromInt = fromInt;
exports.connectToNewWallet = connectToNewWallet;
exports.providerUrl = providerUrl;
exports.chainId = chainId;
exports.provider = provider;
exports.wallet = wallet;
exports.maxFeePerGas = maxFeePerGas;
exports.maxPriorityFeePerGas = maxPriorityFeePerGas;
exports.gasLimit = gasLimit;
exports.txOptions = txOptions;
exports.demoReadyOnly = demoReadyOnly;
exports.demoWrite = demoWrite;
/* env Not a pure module */
