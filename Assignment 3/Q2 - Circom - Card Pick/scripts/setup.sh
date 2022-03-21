#!/bin/bash

# Cleanup leftover files
bash cleanup.sh

# Move up a level to main directory
cd ..

# Install dependencies
yarn install

# Compile the circuit into a system of representative arithmetic equations
# --r1cs generates a binary format of R1CS constraint system of the circuit
# --wasm generates a directory ./cardPick_js containing the wasm code and corresponding files needed for subsequent computation of witness
# --sym generates a symbols file required for debugging or printing the constraint system with annotations
circom cardPick.circom --r1cs --wasm --sym
circom cardReveal.circom --r1cs --wasm --sym

# Trusted setup

# 1. Powers of Tau
# Can be obtained from trusted sources and skipped if preferred

# Start a new powersoftau ceremony
# 11 is the power of two of the maximum number of constraints that the ceremony can accept (in this case, 2 ^ 11 = 2k; Increase to accommodate for more constraints if necessary
snarkjs powersoftau new bn128 11 pot11_0000.ptau -v

# Optional: contribute to the started ceremony
# snarkjs powersoftau contribute pot11_0000.ptau pot11_0001.ptau --name="First contribution" -v -e="random text"

# Prepare for phase 2
snarkjs powersoftau prepare phase2 pot11_0000.ptau pot11_final.ptau -v

# 2. Phase 2
# Circuit specific, must be carried out for unique circuits

# Generate a .zkey file that contains the proving keys, verification keys and all optional phase 2 contributions
snarkjs groth16 setup cardPick.r1cs pot11_final.ptau cardPick_0000.zkey
snarkjs groth16 setup cardReveal.r1cs pot11_final.ptau cardReveal_0000.zkey

# Optional: contribute to the phase 2 ceremony
# snarkjs zkey contribute cardPick_0000.zkey cardPick_0001.zkey --name="1st Contributor Name" -v -e="random text"

# Export verification key to a .json file
snarkjs zkey export verificationkey cardPick_0000.zkey verification_keyCP.json
snarkjs zkey export verificationkey cardReveal_0000.zkey verification_keyCR.json

# Generate verifier.sol
snarkjs zkey export solidityverifier cardPick_0000.zkey verifierCP.sol
snarkjs zkey export solidityverifier cardReveal_0000.zkey verifierCR.sol

# Move into ./contracts
mv verifierCP.sol ./contracts
mv verifierCR.sol ./contracts