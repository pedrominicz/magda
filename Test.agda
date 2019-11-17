{-
 - Yes!
 -}

data ℕ : Set where
    zero : ℕ
    suc  : ℕ → ℕ

{-# BUILTIN NATURAL ℕ #-}

infixl 6 _+_
infixl 7 _*_

_+_ : ℕ → ℕ → ℕ
zero    + n = n
(suc m) + n = suc (m + n)

_*_ : ℕ → ℕ → ℕ
zero    * n = zero
(suc m) * n = n + m * n

goal : ℕ → ℕ
goal = ?

-- zero + suc zero
-- suc zero + suc zero
-- suc (suc zero) + suc zero
--
-- 7 + 7
-- 14 * 14
