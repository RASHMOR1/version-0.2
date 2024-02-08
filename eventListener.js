const Web3 = require('web3');
const web3 = new Web3('http://127.0.0.1:8545'); // replace with your RPC URL

const contractABI = []; // replace with your contract's ABI
const contractAddress = ''; // replace with your contract's address

const contract = new web3.eth.Contract(contractABI, contractAddress);

contract.events.Done({}, (error, event) => {
    if (error) {
        console.error('Error:', error);
    } else {
        console.log('Done event:', event);
    }
});