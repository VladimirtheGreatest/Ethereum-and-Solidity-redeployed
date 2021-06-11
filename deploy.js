const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const {interface, bytecode} = require('../compile');

//mnemonic + rinkeby provider from infura
const provider = new HDWalletProvider(
    'candy deputy grab bubble gesture wet legal fame clawwing retire crucial',
    'https://rinkeby.infura.io/v3/3010037103b9404c8f4b863207d6fc86'
);

const web3 = new Web3(provider);