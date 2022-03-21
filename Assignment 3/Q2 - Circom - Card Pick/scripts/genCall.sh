#!/bin/bash

# Print call arguments
mv publicCP.json public.json
mv proofCP.json proof.json
snarkjs generatecall
mv public.json publicCP.json
mv proof.json proofCP.json

mv publicCR.json public.json
mv proofCR.json proof.json
snarkjs generatecall
mv public.json publicCR.json
mv proof.json proofCR.json