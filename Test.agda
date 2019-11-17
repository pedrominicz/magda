data ℕ : Set where
    zero : ℕ
    suc  : ℕ → ℕ

_+_ : ℕ → ℕ → ℕ
zero    + n = n
(suc m) + n = suc (m + n)

goal : ℕ → ℕ
goal = ?

-- zero + suc zero
-- suc zero + suc zero
-- suc (suc zero) + suc zero
