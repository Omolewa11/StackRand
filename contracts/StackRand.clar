
;; StackRand
;; Secure Random Number Generator
;; A Clarity utility that combines multiple entropy sources to generate verifiably random numbers

;; Error codes
(define-constant ERR_INVALID_RANGE (err u100))
(define-constant ERR_ZERO_RANGE (err u101))
(define-constant ERR_SAME_BLOCK (err u102))

;; Define data variables
(define-data-var entropy-accumulator (buff 32) 0x0000000000000000000000000000000000000000000000000000000000000000)
(define-data-var last-block-height uint u0)
(define-data-var nonce uint u0)

;; Convert uint to buffer (simple implementation for entropy)
(define-private (uint-to-buff (value uint))
  (let
    (
      (byte-0 (mod value u256))
      (byte-1 (mod (/ value u256) u256))
      (byte-2 (mod (/ value u65536) u256))
      (byte-3 (mod (/ value u16777216) u256))
    )
    (concat 
      (concat 
        (buff-to-byte byte-0)
        (buff-to-byte byte-1))
      (concat 
        (buff-to-byte byte-2)
        (buff-to-byte byte-3)))
  )
)

;; Convert integer (0-255) to a single byte buffer
(define-private (buff-to-byte (value uint))
  (unwrap-panic (element-at 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff value))
)

;; Combine entropy sources into a single hash
(define-private (combine-entropy (user-seed (buff 32)))
  (let 
    (
      ;; Get Stacks block header hashes (recent + previous)
      (stacks-hash (unwrap-panic (get-stacks-block-info? header-hash (- stacks-block-height u1))))
      (prev-stacks-hash (unwrap-panic (get-stacks-block-info? header-hash (- stacks-block-height u2))))
      
      ;; Current transaction data - use burn block info
      (burn-hash (unwrap-panic (get-burn-block-info? header-hash (- burn-block-height u1))))
      
      ;; Use tx-sender as an entropy source 
      (sender-bytes (unwrap-panic (to-consensus-buff? tx-sender)))
      
      ;; Current state
      (current-entropy (var-get entropy-accumulator))
      (current-nonce (var-get nonce))
      (nonce-bytes (uint-to-buff current-nonce))
      
      ;; Combine all entropy sources
      (combined-entropy (sha256 (concat 
                                  (concat stacks-hash prev-stacks-hash)
                                  (concat 
                                    (concat burn-hash sender-bytes)
                                    (concat current-entropy (sha256 nonce-bytes))))))
    )
    combined-entropy
  )
)

