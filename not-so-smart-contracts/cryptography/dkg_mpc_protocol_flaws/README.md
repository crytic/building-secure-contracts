# DKG and MPC Protocol Flaws

Subtle bugs in multi-party key generation protocols break security even when the underlying cryptography is correct.

## Description

Distributed key generation (DKG) and multi-party computation (MPC) protocols coordinate multiple participants through structured message rounds to jointly generate keys or compute signatures without any single party holding the full secret. Because these protocols involve complex multi-round state machines, subtle implementation bugs can break the security model entirely -- even when the underlying cryptographic primitives are correct.

Common flaws include failing to validate the degree of shared polynomials in Feldman VSS, allowing a malicious participant to silently raise the reconstruction threshold; poor abort handling that lets an adversary leak secret bits through selective failures or deny service by triggering unilateral aborts; and reuse of session identifiers that enables cross-session message replay, leading to state corruption or key compromise.

## Exploit Scenario

Alice deploys a threshold wallet that uses a Feldman VSS-based DKG protocol with threshold `t = 3` among five participants. Bob, a malicious participant, sends commitments for a degree-5 polynomial instead of degree-3. The verification function does not check `len(commitments) == t + 1`, so it accepts the oversized polynomial. The effective reconstruction threshold silently rises, and the honest participants can no longer sign transactions because they need more shares than expected. Bob then selectively aborts OT sub-protocol sessions to leak bits of other participants' secret shares over time. Because the abort handler panics without identifying the cheater, Bob replays old session messages into new DKG rounds, corrupting the shared secret and locking the wallet funds permanently.

## Example

A DKG share verification function receives commitments from each participant but does not enforce that the polynomial has exactly degree `t`. A malicious participant sends `t + 2` coefficients, silently raising the threshold needed to reconstruct the key.

```pseudocode
function verify_share(participant_id, share, commitments[], t):
    // BUG: no check that len(commitments) == t + 1
    // A malicious participant can send t + 3 commitments,
    // effectively using a degree-(t+2) polynomial instead of degree-t.

    expected = commitments[0]
    for j = 1 to len(commitments) - 1:
        expected = expected + commitments[j] * (participant_id ^ j)

    if expected != share * G:
        // BUG: just returns an error to the caller instead of
        // triggering a coordinated abort with blame proof.
        // A malicious node can flood invalid shares, causing
        // honest participants to abort unilaterally (DoS).
        return error("invalid share")

    return ok
```

Selective abort attacks exploit error handling in oblivious transfer (OT) sub-protocols. The
receiver sends special check values to detect cheating. If the protocol just panics on error
instead of identifying the cheater, a malicious receiver can selectively trigger or suppress
aborts to leak bits of the sender's secret over many sessions:

```pseudocode
function handle_ot_check(check_value, expected):
    if check_value != expected:
        // BUG: panic aborts the entire session without blame.
        // A malicious receiver can:
        //   1. Send a bad check value when the sender's secret bit is 0
        //   2. Send a good check value when the sender's secret bit is 1
        // By observing which sessions abort, the receiver learns one
        // secret bit per session and reconstructs the key over time.
        panic("OT check failed")
```

Message replay across sessions occurs when session IDs are not unique. An attacker records
messages from a previous DKG session and injects them into a new session:

```pseudocode
function process_dkg_message(sender, round, payload):
    // BUG: no session binding -- message from session #1 accepted in session #2
    // An attacker replays old commitments, causing participants to derive
    // different keys and corrupting the shared secret.
    store_commitment(sender, round, payload)
```

## Mitigations

- Validate that every received polynomial has exactly `t + 1` coefficients and reject messages with unexpected lengths before any further processing
- Implement blame and identify protocols so that abort handling attributes the fault to a specific participant rather than allowing silent denial of service
- Generate unique session IDs bound to the participant set, round number, and fresh randomness; reject any message whose session tag does not match the current session
- Authenticate all protocol messages (e.g., with sender signatures) before parsing or processing them, preventing replay and injection attacks
- In oblivious transfer sub-protocols, ensure cheating detection identifies the specific malicious party rather than panicking, to prevent selective abort attacks that leak secret bits across sessions
