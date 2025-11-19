;; ===========================================================================
;; Storage Box - Full Production-Style Clarity Contract
;; ===========================================================================
;; Features:
;; 1. Stores a single unsigned integer (uint) securely.
;; 2. Only owner can update the value (enforced access control).
;; 3. Provides read-only getter.
;; 4. Maintains historical log of changes (mapping block -> value).
;; 5. Supports ownership transfer.
;; 6. Optional value validation (min/max range).
;; 7. Structured error codes for predictable responses.
;; 8. Designed for auditability and easy extension.

;; ===========================================================================
;; Error Codes
;; ===========================================================================
(define-constant ERR_UNAUTHORIZED u100)   ;; caller is not contract owner
(define-constant ERR_VALUE_TOO_LARGE u101) ;; value exceeds allowed max
(define-constant ERR_VALUE_TOO_SMALL u102) ;; value below allowed min

;; ===========================================================================
;; Configurable Constants
;; ===========================================================================
(define-constant MAX_VALUE u1000000) ;; Maximum allowed value
(define-constant MIN_VALUE u0)       ;; Minimum allowed value

;; ===========================================================================
;; State Variables
;; ===========================================================================
;; Owner of the contract (deployer by default)
(define-data-var contract-owner principal tx-sender)

;; The main stored value
(define-data-var stored-value uint u0)

;; Historical log: map of event id -> (value, setter)
(define-data-var event-counter uint u0)
(define-map value-events {event-id: uint} {value: uint, setter: principal})

;; ===========================================================================
;; PUBLIC FUNCTIONS
;; ===========================================================================

;; -------------------------------
;; Set a new value
;; -------------------------------
(define-public (set-value (new-value uint))
  (let ((caller tx-sender)
        (owner (var-get contract-owner)))
    (begin
      ;; Access control: only owner can set value
      (asserts! (is-eq caller owner) (err ERR_UNAUTHORIZED))

      ;; Optional validation
      (asserts! (<= new-value MAX_VALUE) (err ERR_VALUE_TOO_LARGE))
      (asserts! (>= new-value MIN_VALUE) (err ERR_VALUE_TOO_SMALL))

      ;; Update the stored value
      (var-set stored-value new-value)

      ;; Log event in value-events map using an incrementing event id
      (let ((next-id (+ (var-get event-counter) u1)))
        (var-set event-counter next-id)
        (map-set value-events
                 {event-id: next-id}
                 {value: new-value, setter: caller}))

      ;; Return success with the new value
      (ok new-value))))

;; -------------------------------
;; Read the current value
;; -------------------------------
(define-read-only (get-value)
  (ok (var-get stored-value)))

;; -------------------------------
;; Get event by id
;; -------------------------------
(define-read-only (get-event (event-num uint))
  ;; <CHANGE> Fixed match syntax for optional type - use correct 4-argument format
  (match (map-get? value-events {event-id: event-num})
    entry (ok entry)
    (ok {value: u0, setter: tx-sender})))

;; -------------------------------
;; Transfer ownership
;; -------------------------------
(define-public (transfer-ownership (new-owner principal))
  (let ((caller tx-sender)
        (owner (var-get contract-owner)))
    (begin
      ;; Only current owner can transfer ownership
      (asserts! (is-eq caller owner) (err ERR_UNAUTHORIZED))
      (var-set contract-owner new-owner)
      (ok new-owner))))

;; -------------------------------
;; Read-only: Get current owner
;; -------------------------------
(define-read-only (get-owner)
  (ok (var-get contract-owner)))

;; ===========================================================================
;; OPTIONAL EXTENSIONS (commented)
;; ===========================================================================
;; You could extend this contract with:
;; 1. Upgradeable storage pattern: store version number in a data-var
;; 2. Multiple named variables: map name -> value
;; 3. Event pagination helpers
;; 4. Admin roles with different permissions
;; 5. On-chain fee or payment required to set value