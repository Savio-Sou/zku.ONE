#!/bin/bash

# Move up a level then into cardPick_js
cd ../cardPick_js

# Create an input file for picking a card with traits "trait1" and "trait2" concealed by integer "secret"
cat <<EOF > ./inputCP.json
{
    "trait1": 13,
    "trait2": 4,
    "secret": 25565
}
EOF

# Compute the witness
node generate_witness.js cardPick.wasm inputCP.json witnessCP.wtns

# Move back up a level with the witness file 
mv witnessCP.wtns ..
cd ..

# Generate the proof

# Generate a Groth16 zk-proof (proof.json) and summary of public signals (public.json)
snarkjs groth16 prove cardPick_0000.zkey witnessCP.wtns proofCP.json publicCP.json

# Verify the proof

# Verify the proof; outputs "OK!" if proof is valid
snarkjs groth16 verify verification_keyCP.json publicCP.json proofCP.json