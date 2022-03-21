#!/bin/bash

# Move up a level then into cardReveal_js
cd ../cardReveal_js

# Create an input file for revealing a picked card's trait "trait" using the integer "secret" used during card pick
cat <<EOF > ./inputCR.json
{
    "trait": 13,
    "secret": 25565
}
EOF

# Compute the witness
node generate_witness.js cardReveal.wasm inputCR.json witnessCR.wtns

# Move back up a level with the witness file 
mv witnessCR.wtns ..
cd ..

# Generate the proof

# Generate a Groth16 zk-proof (proof.json) and summary of public signals (public.json)
snarkjs groth16 prove cardReveal_0000.zkey witnessCR.wtns proofCR.json publicCR.json

# Verify the proof

# Verify the proof; outputs "OK!" if proof is valid
snarkjs groth16 verify verification_keyCR.json publicCR.json proofCR.json