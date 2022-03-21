pragma circom 2.0.3;

// Optional: include "node_modules/circomlib/circuits/multiplexer.circom"; // For dynamic LessEqThan
include "node_modules/circomlib/circuits/comparators.circom";
include "node_modules/circomlib/circuits/poseidon.circom";

template cardPick(t1Max, t2Max) {
    // Card traits
    signal input trait1; // e.g. Poker card's index
    signal input trait2; // e.g. Poker card's suit
    // Secret, ideally complex and unique; used when trait reveal
    signal input secret;
    // Card uniqueness hash commitment, to be saved on-chain
    signal output cardCommit;
    // Trait hash commitments, to be saved on-chain
    signal output t1Commit; 
    signal output t2Commit;

    // Check validity of trait inputs
    
    // Check non-zero
    component iz1 = IsZero();
    component iz2 = IsZero();
    iz1.in <== trait1;
    iz2.in <== trait2;
    iz1.out === 0;
    iz2.out === 0;

    // Check within maxmimum variation ranges defined
    component let1 = LessEqThan(8); // Optional: component let1 = LessEqThan(log2(t1Max)); // Dynamic LessEqThan
    component let2 = LessEqThan(8);
    let1.in[0] <== trait1;
    let1.in[1] <== t1Max;
    let2.in[0] <== trait2;
    let2.in[1] <== t2Max;
    let1.out === 1;
    let2.out === 1;

    // Generate hash commitments

    // Generate card uniqueness hash commitment
    // Optional TODO: If each player has a unique deck, include secrets into the hash 
    component hashCardCommit = Poseidon(2);
    hashCardCommit.inputs[0] <== trait1;
    hashCardCommit.inputs[1] <== trait2;

    // Generate hashes of secret for concealing traits
    component hashT1Secret = Poseidon(2);
    component hashT2Secret = Poseidon(2);
    hashT1Secret.inputs[0] <== secret;
    hashT1Secret.inputs[1] <== 1;
    hashT2Secret.inputs[0] <== secret;
    hashT2Secret.inputs[1] <== 2;

    // Generate trait hash commitments
    component hashT1Commit = Poseidon(2);
    component hashT2Commit = Poseidon(2);
    hashT1Commit.inputs[0] <== trait1;
    hashT1Commit.inputs[1] <== hashT1Secret.out;
    hashT2Commit.inputs[0] <== trait2;
    hashT2Commit.inputs[1] <== hashT2Secret.out;

    // Outputs
    cardCommit <== hashCardCommit.out;
    t1Commit <== hashT1Commit.out;
    t2Commit <== hashT2Commit.out;
}

// Sample poker implementaion with 13 indices and 4 suits
component main = cardPick(13, 4);