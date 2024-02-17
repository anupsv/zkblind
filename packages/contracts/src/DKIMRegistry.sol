// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDKIMRegistry.sol";

contract DKIMRegistry is IDKIMRegistry {
    event DKIMPublicKeyHashRegistered(string domainName, bytes32 publicKeyHash);
    event DKIMPublicKeyHashRevoked(bytes32 publicKeyHash);

    // Mapping from domain name to DKIM public key hash
    mapping(string => mapping(bytes32 => bool)) public dkimPublicKeyHashes;

    // DKIM public that are revoked (eg: in case of private key compromise)
    mapping(bytes32 => bool) public revokedDKIMPublicKeyHashes;

    function _stringEq(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function isDKIMPublicKeyHashValid(
        string memory domainName,
        bytes32 publicKeyHash
    ) public view returns (bool) {
        if (revokedDKIMPublicKeyHashes[publicKeyHash]) {
            return false;
        }

        if (dkimPublicKeyHashes[domainName][publicKeyHash]) {
            return true;
        }

        return false;
    }

    function setDKIMPublicKeyHash(
        string memory domainName,
        bytes32 publicKeyHash
    ) public {
        require(
            !revokedDKIMPublicKeyHashes[publicKeyHash],
            "cannot set revoked pubkey"
        );

        dkimPublicKeyHashes[domainName][publicKeyHash] = true;

        emit DKIMPublicKeyHashRegistered(domainName, publicKeyHash);
    }

    function setDKIMPublicKeyHashes(
        string memory domainName,
        bytes32[] memory publicKeyHashes
    ) public {
        for (uint256 i = 0; i < publicKeyHashes.length; i++) {
            setDKIMPublicKeyHash(domainName, publicKeyHashes[i]);
        }
    }

    function revokeDKIMPublicKeyHash(bytes32 publicKeyHash) public {
        revokedDKIMPublicKeyHashes[publicKeyHash] = true;

        emit DKIMPublicKeyHashRevoked(publicKeyHash);
    }
}
