const hre = require('hardhat')
const { ethers, waffle } = hre
const { loadFixture } = waffle
const { expect } = require('chai')
const { utils } = ethers

const { toFixedHex } = require('../src/utils')
const Utxo = require('../src/utxo')
const { transaction, prepareTransaction } = require('../src/index')
const { Keypair } = require('../src/keypair')
const { encodeDataForBridge } = require('./utils')

const MERKLE_TREE_HEIGHT = 5
const l1ChainId = 1
const MINIMUM_WITHDRAWAL_AMOUNT = utils.parseEther(process.env.MINIMUM_WITHDRAWAL_AMOUNT || '0.05')
const MAXIMUM_DEPOSIT_AMOUNT = utils.parseEther(process.env.MAXIMUM_DEPOSIT_AMOUNT || '1')

describe("Custom", function () {
    this.timeout(20000)

    // Set-up

    async function deploy(contractName, ...args) {
        const Factory = await ethers.getContractFactory(contractName)
        const instance = await Factory.deploy(...args)
        return instance.deployed()
    }

    async function fixture() {
        require('../scripts/compileHasher')
        const [sender, gov, l1Unwrapper, multisig] = await ethers.getSigners()
        const verifier2 = await deploy('Verifier2')
        const verifier16 = await deploy('Verifier16')
        const hasher = await deploy('Hasher')

        const merkleTreeWithHistory = await deploy(
            'MerkleTreeWithHistoryMock',
            MERKLE_TREE_HEIGHT,
            hasher.address,
        )
        await merkleTreeWithHistory.initialize()

        const token = await deploy('PermittableToken', 'Wrapped ETH', 'WETH', 18, l1ChainId)
        await token.mint(sender.address, utils.parseEther('10000'))

        const amb = await deploy('MockAMB', gov.address, l1ChainId)
        const omniBridge = await deploy('MockOmniBridge', amb.address)

        /** @type {TornadoPool} */
        const tornadoPoolImpl = await deploy(
            'TornadoPool',
            verifier2.address,
            verifier16.address,
            MERKLE_TREE_HEIGHT,
            hasher.address,
            token.address,
            omniBridge.address,
            l1Unwrapper.address,
            gov.address,
            l1ChainId,
            multisig.address,
        )

        const { data } = await tornadoPoolImpl.populateTransaction.initialize(
            MINIMUM_WITHDRAWAL_AMOUNT,
            MAXIMUM_DEPOSIT_AMOUNT,
        )
        const proxy = await deploy(
            'CrossChainUpgradeableProxy',
            tornadoPoolImpl.address,
            gov.address,
            data,
            amb.address,
            l1ChainId,
        )

        const tornadoPool = tornadoPoolImpl.attach(proxy.address)

        await token.approve(tornadoPool.address, utils.parseEther('10000'))

        return { merkleTreeWithHistory, tornadoPool, token, proxy, omniBridge, amb, gov, multisig }
    }

    // Tests

    it("Custom test on leaves insertion gas cost and balance update after a deposit and withdrawal", async function () {
        const { merkleTreeWithHistory, tornadoPool, token, omniBridge } = await loadFixture(fixture)
        const aliceKeypair = new Keypair() // contains private and public keys

        // 1. Print gas cost of inserting a pair of leaves to MerkleTreeHistory
        const gas = await merkleTreeWithHistory.estimateGas.insert(toFixedHex(123), toFixedHex(456))
        console.log('Leaf pair insertion gas:', gas - 21000)

        // 2. Assert recipient, omniBridge, and tornadoPool balances are correctly updated after deposit in L1 and withdrawal in L2

        // Alice bridges and deposits into tornado pool

        // Prepare deposit transaction
        const aliceDepositAmount = utils.parseEther('0.08')
        const aliceDepositUtxo = new Utxo({ amount: aliceDepositAmount, keypair: aliceKeypair })
        const { args, extData } = await prepareTransaction({
            tornadoPool,
            outputs: [aliceDepositUtxo],
        })

        // Prepare bridging transaction
        const onTokenBridgedData = encodeDataForBridge({
            proof: args,
            extData,
        })
        const onTokenBridgedTx = await tornadoPool.populateTransaction.onTokenBridged(
            token.address,
            aliceDepositUtxo.amount,
            onTokenBridgedData,
        )

        // Send tokens to omnibridge mock
        await token.transfer(omniBridge.address, aliceDepositAmount)
        const transferTx = await token.populateTransaction.transfer(tornadoPool.address, aliceDepositAmount)

        // Send tokens to tornado pool
        await omniBridge.execute([
            { who: token.address, callData: transferTx.data }, // send tokens to pool
            { who: tornadoPool.address, callData: onTokenBridgedTx.data }, // call onTokenBridgedTx
        ])

        // Withdraw a part of Alice's funds from the shielded pool to recipient
        const aliceWithdrawAmount = utils.parseEther('0.05')
        const recipient = '0xDeaD00000000000000000000000000000000BEEf'
        const aliceChangeUtxo = new Utxo({
            amount: aliceDepositAmount.sub(aliceWithdrawAmount),
            keypair: aliceKeypair,
        })
        await transaction({
            tornadoPool,
            inputs: [aliceDepositUtxo],
            outputs: [aliceChangeUtxo],
            recipient: recipient,
            isL1Withdrawal: false,
        })

        // Check recipient's L2 balance
        const recipientBalance = await token.balanceOf(recipient)
        expect(recipientBalance).to.be.equal(aliceWithdrawAmount)

        // Check total tokens bridged back to L1
        const omniBridgeBalance = await token.balanceOf(omniBridge.address)
        expect(omniBridgeBalance).to.be.equal(0)

        // Check remaining deposits in L2 tornado pool (i.e. Alice's remaining balance in pool)
        const tornadoPoolBalance = await token.balanceOf(tornadoPool.address)
        expect(tornadoPoolBalance).to.be.equal(aliceChangeUtxo.amount)
    });
});
