// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./DKIMRegistry.sol";
import "@zk-email/contracts/utils/StringUtils.sol";
import { Verifier } from "./Verifier.sol";


contract ProofOfBlind {
    using Counters for Counters.Counter;
    using StringUtils for *;

    uint16 public constant bytesInPackedBytes = 31;
    string constant domain = "x.com";

    uint32 public constant pubKeyHashIndexInSignals = 0; // index of DKIM public key hash in signals array
    uint32 public constant usernameIndexInSignals = 1; // index of first packed twitter username in signals array
    uint32 public constant usernameLengthInSignals = 1; // length of packed twitter username in signals array
    uint32 public constant addressIndexInSignals = 2; // index of ethereum address in signals array

    Counters.Counter private tokenCounter;
    DKIMRegistry dkimRegistry;
    Verifier public immutable verifier;

    mapping(uint256 => string) public tokenIDToName;

    event AddressValidityPass(address sender);
    event DKIMVerificationPass(string domain, bytes32 dkimPublicKeyHashInCircuit);
    event JoinedGroup(uint256 identityCommitment);

    constructor(Verifier v, DKIMRegistry d) {
        verifier = v;
        dkimRegistry = d;
    }

    function _domainCheck(uint256[] memory headerSignals) public pure returns (bool) {
        string memory senderBytes = StringUtils.convertPackedBytesToString(headerSignals, 18, bytesInPackedBytes);
        string[2] memory domainStrings = ["verify@x.com", "info@x.com"];
        return
            StringUtils.stringEq(senderBytes, domainStrings[0]) || StringUtils.stringEq(senderBytes, domainStrings[1]);
    }

    function join(uint256[8] memory proof, uint256[4] memory signals) public {
        // Check eth address committed to in proof matches msg.sender, to avoid replayability
        require(address(uint160(signals[addressIndexInSignals])) == msg.sender, "Invalid address");
        emit AddressValidityPass(msg.sender);

        // Verify the DKIM public key hash stored on-chain matches the one used in circuit
        bytes32 dkimPublicKeyHashInCircuit = bytes32(signals[pubKeyHashIndexInSignals]);
        require(dkimRegistry.isDKIMPublicKeyHashValid(domain, dkimPublicKeyHashInCircuit), "invalid dkim signature");

        emit DKIMVerificationPass(domain, dkimPublicKeyHashInCircuit);

        // Veiry RSA and proof
        require(
            verifier.verifyProof(
                [proof[0], proof[1]],
                [[proof[2], proof[3]], [proof[4], proof[5]]],
                [proof[6], proof[7]],
                signals
            ),
            "Invalid Proof"
        );

        emit JoinedGroup(signals[3]);

    }

}