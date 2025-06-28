

# StackRand – Verifiable Randomness on Stacks Blockchain

**Secure RNG** is a Clarity smart contract designed for generating **verifiably random numbers** on the Stacks blockchain. It combines multiple sources of on-chain entropy to ensure unpredictability, fairness, and resistance to manipulation, even by miners or validators.

---

## 🌟 Features

* 🎲 **Random Number Generation** with user-provided seeds
* 🛡️ **Verifiable Entropy Sources** from on-chain block data
* 🔁 **Internal State Accumulation** for enhanced randomness over time
* 🧱 **Prevention of Same-Block Attacks**
* 📏 **Range-Specific Random Numbers**
* 🔍 **Entropy State Inspection**

---

## 🔧 How It Works

The contract mixes the following entropy sources:

* Current and previous **Stacks block hashes**
* Most recent **burn block hash**
* **Transaction sender address** in consensus-buff format
* A **user-provided 32-byte seed**
* An internal **nonce** that increments per request
* A persistent **entropy accumulator** that evolves over time

All entropy sources are combined using the `sha256` hash function.

---

## 🧪 API Reference

### `get-random (user-seed (buff 32)) (max-value uint) → (response uint)`

Generates a random unsigned integer between `0` and `max-value` (inclusive).

#### Parameters:

* `user-seed`: A 32-byte buffer as external entropy (e.g., timestamp, wallet salt).
* `max-value`: Maximum value (inclusive) the RNG can return.

#### Errors:

* `ERR_ZERO_RANGE` (100): If `max-value` is 0.
* `ERR_SAME_BLOCK` (102): If called more than once per block.

---

### `get-random-in-range (user-seed (buff 32)) (min-value uint) (max-value uint) → (response uint)`

Returns a random unsigned integer between `min-value` and `max-value` (inclusive).

#### Errors:

* `ERR_INVALID_RANGE` (100): If `min-value` > `max-value`.
* Inherits all errors from `get-random`.

---

### `get-entropy-state → (buff 32)`

Returns the current state of the entropy accumulator for verification/debugging.

---

## 🔐 Security Mechanisms

* **Same-Block Execution Prevention**: Prevents multiple calls within the same block to avoid manipulation.
* **Cumulative Entropy**: Each random call updates the accumulator to reduce predictability.
* **Non-Repeatable Results**: Uses unique data per call (sender, nonce, block hashes).

---

## 🚫 Known Limitations

* **No Off-Chain Entropy**: Only on-chain data + user-seed is used.
* **One Call Per Block**: For security, only one call per block is allowed per contract.

---

## ✅ Usage Example (Clarity)

```clarity
(define-constant user-seed 0x1a2b3c4d5e6f7g8h9i0j1121314151617181920a2b2c2d2e2f3f4f5f6f7f8f9f)
(get-random-in-range user-seed u10 u100)
```

Returns a random number between 10 and 100 (inclusive), using the entropy of the blockchain at the time of execution.

---

## 📜 License

MIT – free to use, modify, and distribute.

---
