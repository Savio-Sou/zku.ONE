// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title Insertable Merkle Tree
 * @author Globallager
 * @notice You can construct a Merkle Tree, add a leaf to the tree and check if a leaf exists in the tree
 */
contract MerkleTree {
    mapping(uint32 => bytes32) public node;
    bytes32 public root;
    uint32 public levels;
    uint32 public nextLeaf;
    uint32 internal maxLeaf;

    /// @param _levels Height of Merkle Tree to be built; maximum count of leaves = 2 ^ _levels
    constructor(uint32 _levels) {
        levels = _levels;
        maxLeaf = uint32(2)**levels;
    }

    /**
     * @dev Add a leaf to the tree; internal function
     * @param hashedLeaf Leaf hashed with keccak256 to be added to tree
     */
    function addLeaf(bytes32 hashedLeaf) internal {
        require(nextLeaf != maxLeaf, "Merkle tree is full. No more leaves can be added");
        node[nextLeaf] = hashedLeaf; // Add hashedLeaf to tree
        updateTree(nextLeaf);
        nextLeaf++;
    }

    /** 
     * @dev Recalculate nodes and root hashes on path based on the new leaf added; internal function, called by addLeaf
     * @param newLeafIndex Index of new leaf added
     */
    function updateTree(uint32 newLeafIndex) internal {
        uint32 nodeIndex = newLeafIndex; // Index of node to be worked on
        bytes32 left;
        bytes32 right;
        uint32 offset; // Accumulative offset depending on level
        uint32 nodeLevelIndex; // Net index of nodeIndex at current level

        for (uint32 i = levels; i > 0; i--) {
            if (nextLeaf % 2 == 0) {
                left = node[nodeIndex];
                right = node[nodeIndex+1];
            } else {
                left = node[nodeIndex-1];
                right = node[nodeIndex];
            }

            nodeLevelIndex = nodeIndex - offset;

            // Move nodeIndex to parent node
            offset += uint32(2)**i;
            nodeIndex = nodeLevelIndex / 2 + offset;

            node[nodeIndex] = keccak256(abi.encodePacked(left, right));
        }

        root = node[nodeIndex]; // Update root, i.e. last updated node
    }

    /** 
     * @dev Check if a leaf exists in the tree
     * @param proof Array of nodes needed to calculate the Merkle root
     * @param hashedLeaf Leaf hashed with keccak256 to be checked for existence
     * @param index Index of the hashedLeaf
     */
    function checkLeafExists(
        bytes32[] memory proof,
        bytes32 hashedLeaf,
        uint index
    ) public view returns (bool) {
        bytes32 hash = hashedLeaf;

        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }

            index = index / 2;
        }

        return hash == root;
    }
}