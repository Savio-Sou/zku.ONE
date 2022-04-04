// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.11;

import "./verifier.sol";

contract PseudoDarkForest is Verifier {
    event TriangleMoveSucceed();
    event TriangleMoveFailed();
    
    function triangleMove(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public {
        if (verifyProof(a, b, c, input)) {
            emit TriangleMoveSucceed();
        } else {
            emit TriangleMoveFailed();
        }
    }
}