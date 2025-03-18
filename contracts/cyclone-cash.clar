(define-map deposits { hash: (string-ascii 64) } { amount: uint, sender: principal })

(define-public (make-deposit (hash (string-ascii 64)) (amount uint))
  (begin
    ;; Ensure the amount is greater than 0
    (asserts! (> amount u0) (err u"Amount must be greater than 0"))

    ;; Store the deposit in the map
    (map-set deposits { hash: hash } { amount: amount, sender: tx-sender })

    ;; Return success
    (ok true)
  )
)

(define-public (withdraw (hash (string-ascii 64)) (recipient principal))
  (let ((deposit-info (map-get? deposits { hash: hash })))
    ;; Ensure the deposit exists
    (asserts! (is-some deposit-info) (err u"Invalid hash"))

    ;; Extract deposit data
    (let ((deposit (unwrap! deposit-info (err u"Failed to unwrap deposit"))))

      ;; Delete the deposit from the map
      (map-delete deposits { hash: hash })

      ;; Transfer the amount to the recipient 
      (unwrap! (stx-transfer? (get amount deposit) tx-sender recipient) (err u"Failed to transfer deposit") )

      ;; Return success
      (ok true)
    )
  )
)