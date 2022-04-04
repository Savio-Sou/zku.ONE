pub fn pseudo_DF_abi() -> String {
    return r#"[
        {
          "anonymous": false,
          "inputs": [],
          "name": "TriangleMoveFailed",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [],
          "name": "TriangleMoveSucceed",
          "type": "event"
        },
        {
          "inputs": [
            {
              "internalType": "uint256[2]",
              "name": "a",
              "type": "uint256[2]"
            },
            {
              "internalType": "uint256[2][2]",
              "name": "b",
              "type": "uint256[2][2]"
            },
            {
              "internalType": "uint256[2]",
              "name": "c",
              "type": "uint256[2]"
            },
            {
              "internalType": "uint256[1]",
              "name": "input",
              "type": "uint256[1]"
            }
          ],
          "name": "triangleMove",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        }
      ]"#.to_string();
}