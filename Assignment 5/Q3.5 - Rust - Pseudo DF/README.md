# Pseudo Dark Forest w/ Triangle Move Caller

A pseudo Dark Forest implementation (circuits + contracts), with a caller in Rust that may call the contract to make a move from planet A -> B -> C -> A, which:
1. The paths form a triangle
2. Each moves are within the energy bounds (i.e. 10)

## Pre-requisite

- Install [yarn](https://classic.yarnpkg.com/lang/en/docs/install/#windows-stable)

## Usage

1. Initialize local network

```console
cd local_contract_deploy
yarn install
yarn hardhat node
```

2. Deploy contracts on local network; open a new terminal and run

```console
make deploy
```

4. Update contract address in `pseudo_df/src/utils/addresses.rs`

5. Build and run contract caller