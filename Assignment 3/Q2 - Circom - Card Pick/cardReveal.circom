pragma circom 2.0.3;

include "node_modules/circomlib/circuits/poseidon.circom";

template cardReveal() {
    signal input trait;
    signal input secret;
    signal output traitCommit;

    // Input validity check enforced at contract level

    // Generate trait hash commitments
    component hashSecret = Poseidon(2);
    component hashTraitCommit = Poseidon(2);
    hashSecret.inputs[0] <== secret;
    hashSecret.inputs[1] <== 1;
    hashTraitCommit.inputs[0] <== trait;
    hashTraitCommit.inputs[1] <== hashSecret.out;

    // Output
    traitCommit <== hashTraitCommit.out;
}

component main {public [trait]} = cardReveal();