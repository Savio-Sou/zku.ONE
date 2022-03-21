// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title GlobalIndex
 * @notice A global index of range 0-255 accessible by anyone
 */
contract GlobalIndex {
    uint8 index;

    /** 
     * @notice Modify the index
     * @param _index the new value of index
     */
    function setIndex(uint8 _index) public {
        index = _index;
    }

    /**
     * @notice Check the current index
     * @return the index
     */
    function currentIndex() public view returns (uint8) {
        return index;
    }
}