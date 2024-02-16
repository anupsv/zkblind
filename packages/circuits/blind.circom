pragma circom 2.1.5;

include "@zk-email/zk-regex-circom/circuits/common/from_addr_regex.circom";
include "@zk-email/circuits/email-verifier.circom";
include "./components/blind_reset_regex.circom";

template BlindVerifier(max_header_bytes, max_body_bytes, n, k, pack_size) {

    signal input in_padded[max_header_bytes];
    signal input pubkey[k];
    signal input signature[k];
    signal input in_len_padded_bytes;

    signal input address;
    signal input semCommitment;
    signal input body_hash_idx;
    signal input precomputed_sha[32];
    signal input in_body_padded[max_body_bytes];
    signal input in_body_len_padded_bytes;

    signal output pubkey_hash;

    component EV = EmailVerifier(max_header_bytes, max_body_bytes, n, k, 0);
    EV.in_padded <== in_padded;
    EV.pubkey <== pubkey;
    EV.signature <== signature;
    EV.in_len_padded_bytes <== in_len_padded_bytes;
    EV.body_hash_idx <== body_hash_idx;
    EV.precomputed_sha <== precomputed_sha;
    EV.in_body_padded <== in_body_padded;
    EV.in_body_len_padded_bytes <== in_body_len_padded_bytes;

    pubkey_hash <== EV.pubkey_hash;


    var max_email_from_len = 30;
    var max_email_from_packed_bytes = count_packed(max_email_from_len, pack_size);
    assert(max_email_from_packed_bytes < max_header_bytes);

    signal input email_from_idx;
    signal output reveal_email_from_packed[max_email_from_packed_bytes];

    signal (from_regex_out, from_regex_reveal[max_header_bytes]) <== FromAddrRegex(max_header_bytes)(in_padded);
    from_regex_out === 1;
    reveal_email_from_packed <== ShiftAndPackMaskedStr(max_header_bytes, max_email_from_len, pack_size)(from_regex_reveal, email_from_idx);


    var max_blind_len = 21;
    var max_blind_packed_bytes = count_packed(max_blind_len, pack_size);
    signal input blind_username_idx;

    signal (blind_regex_out, blind_regex_reveal[max_body_bytes]) <== BlindResetRegex(max_body_bytes)(in_body_padded);
    signal is_found_blind <== IsZero()(blind_regex_out);
    is_found_blind === 0;

}

component main { public [ address, semCommitment ] } = BlindVerifier(1024, 1536, 121, 17, 31);