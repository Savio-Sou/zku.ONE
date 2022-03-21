#!/bin/bash

# Move up a level to main directory
cd ..

# Cleanup leftover files
rm -r node_modules
rm cardPick.r1cs
rm cardPick.sym
rm cardReveal.r1cs
rm cardReveal.sym
rm -r cardPick_*
rm -r cardReveal_*
rm witness*.wtns
rm pot*
rm proof*.json
rm public*.json
rm verification_key*.json
rm contracts/verifier*