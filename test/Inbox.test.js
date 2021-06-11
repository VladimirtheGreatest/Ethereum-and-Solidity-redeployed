const assert = require('assert');
const ganache = require('ganache-cli'); //local test network
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require('../compile');
const INITIAL_STRING = "Bullshit";

let accounts;
let inbox;
beforeEach(async() => {
    //Get a list of all accounts
   accounts = await web3.eth.getAccounts();
    //Use one of those accounts to deploy the contract
    inbox = await new web3.eth
    .Contract(JSON.parse(interface))
    .deploy({data: bytecode, arguments: [INITIAL_STRING]})
    .send({from: accounts[0], gas: '1000000'})
});

describe('Inbox', () => {
    it('deploys a contract', () => {
        assert.ok(inbox.options.address);
    });
    it('has a default message',async () => {
        //inbox instance of contract, methods in the contract, call function readonly, not paying, parentheses usage so we can pass arguments
        const message = await inbox.methods.message().call();
        assert.strictEqual(message, INITIAL_STRING);
    })
});






















































































































