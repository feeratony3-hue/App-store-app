;; appstore-app
;; Clarity contract for a decentralized app store platform

(define-data-var app-counter uint u0)

(define-map apps {id: uint}
  {developer: principal,
   name: (string-ascii 50),
   approved-by: (optional principal),
   status: (string-ascii 10)})

;; Submit a new app
(define-public (submit-app (name (string-ascii 50)))
  (begin
    (asserts! (> (len name) u0) (err u1))
    (let
      (
        (id (var-get app-counter))
      )
      (map-set apps {id: id}
        {developer: tx-sender,
         name: name,
         approved-by: none,
         status: "pending"})
      (var-set app-counter (+ id u1))
      (ok id)
    )
  )
)

;; Approve an app
(define-public (approve-app (id uint))
  (match (map-get? apps {id: id})
    app
    (if (is-eq (get status app) "pending")
      (begin
        (map-set apps {id: id}
          {developer: (get developer app),
           name: (get name app),
           approved-by: (some tx-sender),
           status: "approved"})
        (ok "App approved")
      )
      (err u2)) ;; not pending
    (err u3)) ;; app not found
)

;; Remove an app
(define-public (remove-app (id uint))
  (match (map-get? apps {id: id})
    app
    (if (and (is-eq (get status app) "pending") (is-eq tx-sender (get developer app)))
      (begin
        (map-set apps {id: id}
          {developer: (get developer app),
           name: (get name app),
           approved-by: none,
           status: "removed"})
        (ok "App removed")
      )
      (err u4)) ;; not pending or not developer
    (err u5)) ;; app not found
)