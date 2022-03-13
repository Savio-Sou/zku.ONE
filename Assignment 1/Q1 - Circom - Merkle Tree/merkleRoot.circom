pragma circom 2.0.3;

include "mimcsponge.circom";

template merkleRoot(n) {  
    signal input leaves[n]; 
    signal output root;
    component hashes[n-1];

    // Set up MiMC components
    for (var i = 0; i < n-1; i++) {
        hashes[i] = MiMCSponge(2, 220, 1);
        hashes[i].k <== 0;
    }

    // Feed in leaves (without pre-hashing) as hashing inputs to their parents 
    for (var i = 0, j = 0; i < n; i += 2) {
        hashes[j].ins[0] <== leaves[i];
        hashes[j].ins[1] <== leaves[i+1];
        j++;
    }

    // Iteratively compute hashes and feed the results as hashing inputs to their parents
    for (var i = 0, j = n/2; i < n-2; i += 2) {
        hashes[j].ins[0] <== hashes[i].outs[0];
        hashes[j].ins[1] <== hashes[i+1].outs[0];
        j++;
    }

    // Retrieve last MiMC component's output as root
    root <== hashes[n-2].outs[0];
}

component main {public [leaves]} = merkleRoot(8);