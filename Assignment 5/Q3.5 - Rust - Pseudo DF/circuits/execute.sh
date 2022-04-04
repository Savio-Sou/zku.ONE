#!/bin/bash

# Cleanup leftover files
bash cleanup.sh

# Install dependencies
yarn install

# Compile the circuit into a system of representative arithmetic equations
# --r1cs generates a binary format of R1CS constraint system of the circuit
# --wasm generates a directory ./triangleJump_js containing the wasm code and corresponding files needed for subsequent computation of witness
# --sym generates a symbols file required for debugging or printing the constraint system with annotations
circom triangleJump.circom --r1cs --wasm --sym

# Move into ./triangleJump_js
cd ./triangleJump_js

# Create an input file containing coordinates of planet A, B and C
cat <<EOF > ./input.json
{
    "Ax": 3,
    "Ay": 3,
    "Bx": 1,
    "By": 2,
    "Cx": 5,
    "Cy": 7
}
EOF

# Compute the witness
node generate_witness.js triangleJump.wasm input.json witness.wtns

# Move back up a level with the witness file 
mv witness.wtns ..
cd ..

# Trusted setup

# 1. Powers of Tau
# Can be obtained from trusted sources and skipped if preferred

# Start a new powersoftau ceremony
# 8 is the power of two of the maximum number of constraints that the ceremony can accept (in this case, 2 ^ 8 = 256; Increase to accommodate for more constraints if necessary
snarkjs powersoftau new bn128 8 pot8_0000.ptau -v

# Optional: contribute to the started ceremony
# snarkjs powersoftau contribute pot8_0000.ptau pot8_0001.ptau --name="First contribution" -v -e="random text"

# Prepare for phase 2
snarkjs powersoftau prepare phase2 pot8_0000.ptau pot8_final.ptau -v

# 2. Phase 2
# Circuit specific, must be carried out for unique circuits

# Generate a .zkey file that contains the proving keys, verification keys and all optional phase 2 contributions
snarkjs groth16 setup triangleJump.r1cs pot8_final.ptau triangleJump_0000.zkey

# Optional: contribute to the phase 2 ceremony
# snarkjs zkey contribute triangleJump_0000.zkey triangleJump_0001.zkey --name="1st Contributor Name" -v -e="random text"

# Export verification key to a .json file
snarkjs zkey export verificationkey triangleJump_0000.zkey verification_key.json

# Generate the proof

# Generate a Groth16 zk-proof (proof.json) and summary of public signals (public.json)
snarkjs groth16 prove triangleJump_0000.zkey witness.wtns proof.json public.json

# Verify the proof

# Verify the proof; outputs "OK!" if proof is valid
snarkjs groth16 verify verification_key.json public.json proof.json

# Generate a verifying contract
snarkjs zkey export solidityverifier triangleJump_0000.zkey verifier.sol