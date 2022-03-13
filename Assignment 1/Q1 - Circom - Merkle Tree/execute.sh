#!/bin/bash

# Cleanup leftover files
rm merkleRoot.r1cs
rm merkleRoot.sym
rm -r merkleRoot_*
rm witness.wtns
rm pot*
rm proof.json
rm public.json
rm verification_key.json

# Compile the circuit into a system of representative arithmetic equations
# --r1cs generates a binary format of R1CS constraint system of the circuit
# --wasm generates a directory ./merkleRoot_js containing the wasm code and corresponding files needed for subsequent computation of witness
# --sym generates a symbols file required for debugging or printing the constraint system with annotations
circom merkleRoot.circom --r1cs --wasm --sym

# Move into ./merkleRoot_js
cd ./merkleRoot_js

# Create an input file containing 8 leaves
cat <<EOF > ./input.json
{"leaves": [1, 2, 3, 4, 5, 6, 7, 8]}
EOF

# Compute the witness
node generate_witness.js merkleRoot.wasm input.json witness.wtns

# Move back up a level with the witness file 
mv witness.wtns ..
cd ..

# Trusted setup

# 1. Powers of Tau
# Can be obtained from trusted sources and skipped if preferred

# Start a new powersoftau ceremony
# 14 is the power of two of the maximum number of constraints that the ceremony can accept (in this case, 2 ^ 14 = 16384; Increase to accommodate for more constraints if necessary
snarkjs powersoftau new bn128 14 pot14_0000.ptau -v

# Optional: contribute to the started ceremony
# snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v -e="random text"

# Prepare for phase 2
snarkjs powersoftau prepare phase2 pot14_0000.ptau pot14_final.ptau -v

# 2. Phase 2
# Circuit specific, must be carried out for unique circuits

# Generate a .zkey file that contains the proving keys, verification keys and all optional phase 2 contributions
snarkjs groth16 setup merkleRoot.r1cs pot14_final.ptau merkleRoot_0000.zkey

# Optional: contribute to the phase 2 ceremony
# snarkjs zkey contribute merkleRoot_0000.zkey merkleRoot_0001.zkey --name="1st Contributor Name" -v -e="random text"

# Export verification key to a .json file
snarkjs zkey export verificationkey merkleRoot_0000.zkey verification_key.json

# Generate the proof

# Generate a Groth16 zk-proof (proof.json) and summary of public signals (public.json)
snarkjs groth16 prove merkleRoot_0000.zkey witness.wtns proof.json public.json

# Verify the proof

# Verify the proof; outputs "OK!" if proof is valid
snarkjs groth16 verify verification_key.json public.json proof.json