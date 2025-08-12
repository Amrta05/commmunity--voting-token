;; Community Voting Token (Basic Version)
;; A minimal fungible token for community governance with voting functionality

(define-fungible-token voting-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-amount (err u101))
(define-constant err-insufficient-balance (err u102))

;; Token Info
(define-data-var token-name (string-ascii 32) "Community Voting Token")
(define-data-var token-symbol (string-ascii 10) "CVT")
(define-data-var token-decimals uint u0)
(define-data-var total-supply uint u0)

;; Proposal Votes
(define-map votes uint uint) ;; proposal-id => total votes

;; Function 1: Mint new tokens (Only Owner)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (ft-mint? voting-token amount recipient))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)))

;; Function 2: Vote for a proposal (Token holders only)
(define-public (vote (proposal-id uint) (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= (ft-get-balance voting-token tx-sender) amount) err-insufficient-balance)
    (try! (ft-burn? voting-token amount tx-sender))
    (map-set votes proposal-id
             (+ (default-to u0 (map-get? votes proposal-id)) amount))
    (ok true)))
