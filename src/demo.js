// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Curry = require("rescript/lib/js/curry.js");
var Ethers = require("ethers");
var SecretsManagerJs = require("../secretsManager.js");
var Ethers$FloatJsClient = require("./demo/Ethers.js");
var CONSTANTS$FloatJsClient = require("./demo/CONSTANTS.js");
var MarketSide$FloatJsClient = require("./MarketSide.js");

var env = process.env;

var mnemonic = SecretsManagerJs.mnemonic;

var providerUrl = SecretsManagerJs.providerUrl;

function connectToNewWallet(provider, mnemonic) {
  return new (Ethers.Wallet.fromMnemonic)(mnemonic, "m/44'/60'/0'/0/0").connect(provider);
}

function run(param) {
  var $$float = MarketSide$FloatJsClient.MarketSide.newFloatMarketSide(Ethers$FloatJsClient.getSigner(connectToNewWallet(new (Ethers.providers.JsonRpcProvider)(providerUrl, 137), mnemonic)), Ethers.BigNumber.from(1), true);
  var maxFeePerGas = Ethers.BigNumber.from(62).mul(CONSTANTS$FloatJsClient.oneGweiInWei);
  var maxPriorityFeePerGas = Ethers.BigNumber.from(34).mul(CONSTANTS$FloatJsClient.oneGweiInWei);
  var gasLimit = Ethers.BigNumber.from(600000);
  var txOptions_maxFeePerGas = maxFeePerGas.toString();
  var txOptions_maxPriorityFeePerGas = maxPriorityFeePerGas.toString();
  var txOptions_gasLimit = gasLimit.toString();
  var txOptions = {
    maxFeePerGas: txOptions_maxFeePerGas,
    maxPriorityFeePerGas: txOptions_maxPriorityFeePerGas,
    gasLimit: txOptions_gasLimit
  };
  return Curry._2($$float.shiftStake, Ethers.BigNumber.from(22).mul(CONSTANTS$FloatJsClient.tenToThe18).div(CONSTANTS$FloatJsClient.tenToThe2), txOptions).then(function (tx) {
              console.log(tx.hash);
              
            });
}

run(undefined);

exports.env = env;
exports.mnemonic = mnemonic;
exports.providerUrl = providerUrl;
exports.connectToNewWallet = connectToNewWallet;
exports.run = run;
/* env Not a pure module */
