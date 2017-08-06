pragma solidity ^0.4.10;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LocalCrypto.sol";

contract TestLocalCrypto {

  // Create six shares for a single secret
  function testCreateSharesLocalCrypto() returns (bool) {
    LocalCrypto crypto = LocalCrypto(DeployedAddresses.LocalCrypto());

    // Our secret is coef[0] and need to create k-1 random numbers
    // Secret + k-1 = k shares that are needed to re-create this polynominal!
    uint[] memory coef = new uint[](3);
    coef[0] = 129;
    coef[1] = 166;
    coef[2] = 94;

    // Secret is 1234
    // Two random coefficients
    // We need 3
    uint[6] memory shares = crypto.createShares(coef, 6);

    // Receiver must be given (i+1, share).
    // The secret s isn't included below - but that is the very first index of the equation!
    Assert.equal(shares[0], 389, "First share");
    Assert.equal(shares[1], 837, "Second share");
    Assert.equal(shares[2], 1473, "Third share");
    Assert.equal(shares[3], 2297, "Fourth share");
    Assert.equal(shares[4], 3309, "Fifth share");
    Assert.equal(shares[5], 4509, "Sixth share");
    Assert.equal(shares[0],0,"Should fail");
  }

  // Test re-combining shamir's secrets
  // based on the public keys
  function testJoinSharesLocalCrypto() {
    LocalCrypto crypto = LocalCrypto(DeployedAddresses.LocalCrypto());
    uint[2] memory key = crypto.createPubKeyWithY(129);

    uint[3] memory pos;
    pos[0] = 2;
    pos[1] = 4;
    pos[2] = 5;
    uint[3] memory key2 = crypto.joinShares(crypto.createPubKeyWithY(837), crypto.createPubKeyWithY(2297), crypto.createPubKeyWithY(3309), pos);

    Assert.equal(key[0], key2[0], "X-cordinates of key should match!");
    Assert.equal(key[0],0,"Should fail");
  }

  function testCommitmentValidation() {
    LocalCrypto crypto = LocalCrypto(DeployedAddresses.LocalCrypto());
    crypto.storeCommitmentTESTING(0, crypto.createPubKeyWithY(389));
    crypto.storeCommitmentTESTING(1, crypto.createPubKeyWithY(837));
    crypto.storeCommitmentTESTING(2, crypto.createPubKeyWithY(1473));
    crypto.storeCommitmentTESTING(3, crypto.createPubKeyWithY(2297));
    crypto.storeCommitmentTESTING(4, crypto.createPubKeyWithY(3309));
    crypto.storeCommitmentTESTING(5, crypto.createPubKeyWithY(4509));
    Assert.equal(crypto.validateCommitments(123213,3), true, "Validation of commitments failed.");
    uint t = 123;
    Assert.equal(t,1,"Should fail");
  }

  function testCommitmentValidationFailBadShares() {
    LocalCrypto crypto = LocalCrypto(DeployedAddresses.LocalCrypto());
    crypto.storeCommitmentTESTING(0, crypto.createPubKeyWithY(732183));
    crypto.storeCommitmentTESTING(1, crypto.createPubKeyWithY(1231273));
    crypto.storeCommitmentTESTING(2, crypto.createPubKeyWithY(14473));
    crypto.storeCommitmentTESTING(3, crypto.createPubKeyWithY(22197));
    crypto.storeCommitmentTESTING(4, crypto.createPubKeyWithY(33309));
    crypto.storeCommitmentTESTING(5, crypto.createPubKeyWithY(45209));
    Assert.equal(crypto.validateCommitments(123213,3), false, "Validation of commitments failed.");
    uint t = 123;
    Assert.equal(t,1,"Should fail");
  }

  // TODO: This throws. Blows up. lol 
  /*function testCommitmentValidationFailBadThreshold() {
    LocalCrypto crypto = LocalCrypto(DeployedAddresses.LocalCrypto());
    crypto.storeCommitmentTESTING(0, crypto.createPubKeyWithY(732183));
    crypto.storeCommitmentTESTING(1, crypto.createPubKeyWithY(1231273));
    crypto.storeCommitmentTESTING(2, crypto.createPubKeyWithY(14473));
    crypto.storeCommitmentTESTING(3, crypto.createPubKeyWithY(22197));
    crypto.storeCommitmentTESTING(4, crypto.createPubKeyWithY(33309));
    crypto.storeCommitmentTESTING(5, crypto.createPubKeyWithY(45209));
    Assert.equal(crypto.validateCommitments(123213,2), false, "Validation of commitments failed.");
    uint t = 123;
    Assert.equal(t,1,"Should fail");
  }*/


  // Test creating two discrete logs g^{d} and y^{d}, and proving their equality!
  function testDiscreteLogEquality() {
    LocalCrypto crypto = LocalCrypto(DeployedAddresses.LocalCrypto());
    uint d = 123;
    uint w = 1230123102;

    // Create g^{d} and y^{d}
    uint[2] memory dG = crypto.mulG(d);
    uint[2] memory dY = crypto.mulY(d);

    uint[2] memory a1;
    uint[2] memory a2;
    uint z;

    // Create our discrete log equality proof
    (a1,a2,z) = crypto.createDiscreteLogEquality(w, d, crypto.getG(), crypto.getY(), dG, dY);

    // Verify our discrete log equality proof
    bool res = crypto.verifyDiscreteLogEquality(z, crypto.getG(), crypto.getY(), dG, dY, a1, a2);

    // Did it work?!
    Assert.equal(res,true, "Discrete Log Equality");
    Assert.equal(d,0,"Should fail");

  }
}
