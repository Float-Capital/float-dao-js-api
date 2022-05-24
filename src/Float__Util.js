// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Ethers = require("ethers");
var FloatConfig = require("@float-capital/config/src/FloatConfig.js");

function getChainConfigUsingId(chainId) {
  var config = FloatConfig.getChainConfig(chainId);
  if (config !== undefined) {
    return config;
  } else {
    console.log("Cannot find chain config associated with network ID " + chainId + ", defaulting to Avalanche");
    return FloatConfig.avalancheConfig;
  }
}

function getChainConfig(pw) {
  var tmp;
  tmp = pw.TAG === /* P */0 ? pw._0 : pw._0.provider;
  return tmp.getNetwork().then(function (network) {
              return getChainConfigUsingId(network.chainId);
            });
}

function makeDefaultProvider(config) {
  return new (Ethers.providers.JsonRpcProvider)(config.rpcEndpoint, config.networkId);
}

exports.getChainConfigUsingId = getChainConfigUsingId;
exports.getChainConfig = getChainConfig;
exports.makeDefaultProvider = makeDefaultProvider;
/* ethers Not a pure module */