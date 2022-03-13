# Custom Tornado Cash Nova Test

A custom test case of [Tonado Cash Nova](https://github.com/tornadocash/tornado-nova) which:
1. Prints the estimated gas cost for instering a pair of leaves to MerkleTreeWithHistory
2. Check balance update after an L1 deposit and L2 withdrawal

## Pre-requisite

- Install [yarn](https://classic.yarnpkg.com/lang/en/docs/install/#windows-stable)

## Usage

1. Clone the `tornado-nova` repo:
    ```shell
    git clone https://github.com/tornadocash/tornado-nova.git
    ```

2. Change directory into the repo:
    ```shell
    cd tornado-nova
    ```

3. Build the repo:
    ```shell
    yarn build
    ```

4. Download/Copy the `custom.test.js` here into the `.../tornado-nova/test` folder.

5. Run the tests:
    ```shell
    yarn test
    ```