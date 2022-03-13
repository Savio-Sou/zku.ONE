// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.5.0/utils/Counters.sol";
import "./MerkleTree.sol";

/**
 * @title Open mint of ERC721 tokens
 * @author Globallager
 * @notice You can use this contract to creat NFT tokens
 */
contract TheOpenMint is ERC721, ERC721URIStorage, MerkleTree {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => bytes) private _tokenURIs;

    /**
     * @param collectionName Name of token collection, e.g. "MyToken"
     * @param collectionSymbol Symbol of token collection, e.g. "MTK"
     * @param merkleTreeLevels Height of Merkle Tree to be built for all tokens; maximum count of tokens = 2 ^ merkleTreeLevels
     */
    constructor(
        string memory collectionName,
        string memory collectionSymbol,
        uint32 merkleTreeLevels
    ) ERC721(collectionName, collectionSymbol) MerkleTree(merkleTreeLevels) {}

    /// @dev Sets URI of token; internal function
    function _setTokenURI(uint256 tokenId, bytes memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @notice Mint an NFT of ERC721 format
     * @dev Mint an ERC721 and update the Merkle Tree built on all tokens minted
     * @param to Receiving address of the token
     * @param name Name of token
     * @param description Description of token
     */
    function safeMint(
        address to,
        string memory name,
        string memory description
    ) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "',
            name,
            '",',
            '"description": "',
            description,
            '"',
            "}"
        );

        _setTokenURI(tokenId, dataURI);

        addLeaf(keccak256(abi.encodePacked(msg.sender, to, tokenId, dataURI)));
    }

    // Overriding functions of inherited contracts; required by Solidity

    /// @dev Overriding _burn of inherited contracts; not used
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /**
     * @notice Returns the URI (metadata) of token
     * @dev Overriding tokenURI of inherited contracts
     * @param tokenId Identifier of token
     * @return URI of token in JSON format
     */ 
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(_exists(tokenId), "TheOpenMint: Token does not exist");
        return string(_tokenURIs[tokenId]);
    }
}