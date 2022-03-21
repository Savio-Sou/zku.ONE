# ZK Card Game

A card game framework that utilizes zero-knowledge proofs to conceal card traits.

Currently implemented:
1. Card pick with concealed traits
2. Card trait revealing

## Pre-requisite

- Install [yarn](https://classic.yarnpkg.com/lang/en/docs/install/#windows-stable)

## Usage

For non-Linux users, refer to the `.sh` scripts for commands to run.

For Linux users:

1. Change directory into `scripts`:
    ```bash
    cd scripts
    ```

2. For a full sample run:
    ```bash
    bash fullExecute.sh
    ```

    For a custom run, modify the parameters in `cardPick.circom` to your liking, and sets up the environment:
    ```bash 
    bash setup.sh
    ```

3. Deploy the contracts in `contracts`. First `verifierCP.sol` and `verifierCR.sol`, then `cardGame.sol` with the addresses `verifierCP.sol` and `verifierCR.sol` deployed at as constructing arguments.

    For full sample run, you may skip to Step 6.

4. To prepare for card pick, modify the card to pick and hiding secret in `genProofCP.sh` under `input.json` to your liking and run:
    ``` bash
    bash genProofCP.sh
    ```

5. To prepare for card reveal, use the trait value and hiding secret in `genProofCR.sh` under `input.json` to what was used when card picking, then run:
    ``` bash
    bash genProofCP.sh
    ```

6. Generate contract call arguments:
    ```bash
    bash genCall.sh
    ```
    First set for card pick, second set for card reveal.

7. Perform the card pick and trait reveal on-chain by calling the deployed contract `CardGame` using the generated arguments.

    For trait reveal, `cardCommit` generated when proving card pick or emitted when card picking on-chain and `traitNum` (e.g. 1 for trait1) of the trait to reveal are also needed.