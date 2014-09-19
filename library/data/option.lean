-- Copyright (c) 2014 Microsoft Corporation. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Author: Leonardo de Moura

import logic.core.eq logic.core.inhabited logic.core.decidable
open eq_ops decidable

inductive option (A : Type) : Type :=
  none {} : option A,
  some    : A → option A

namespace option
  protected theorem induction_on {A : Type} {p : option A → Prop} (o : option A)
    (H1 : p none) (H2 : ∀a, p (some a)) : p o :=
  rec H1 H2 o

  protected definition rec_on {A : Type} {C : option A → Type} (o : option A)
    (H1 : C none) (H2 : ∀a, C (some a)) : C o :=
  rec H1 H2 o

  definition is_none {A : Type} (o : option A) : Prop :=
  rec true (λ a, false) o

  theorem is_none_none {A : Type} : is_none (@none A) :=
  trivial

  theorem not_is_none_some {A : Type} (a : A) : ¬ is_none (some a) :=
  not_false_trivial

  theorem none_ne_some {A : Type} (a : A) : none ≠ some a :=
  assume H : none = some a, absurd
    (H ▸ is_none_none)
    (not_is_none_some a)

  protected theorem equal {A : Type} {a₁ a₂ : A} (H : some a₁ = some a₂) : a₁ = a₂ :=
  congr_arg (option.rec a₁ (λ a, a)) H

  protected theorem is_inhabited [instance] (A : Type) : inhabited (option A) :=
  inhabited.mk none

  protected theorem has_decidable_eq [instance] {A : Type} (H : decidable_eq A) : decidable_eq (option A) :=
  take o₁ o₂ : option A,
    rec_on o₁
      (rec_on o₂ (inl rfl) (take a₂, (inr (none_ne_some a₂))))
      (take a₁ : A, rec_on o₂
        (inr (ne.symm (none_ne_some a₁)))
        (take a₂ : A, decidable.rec_on (H a₁ a₂)
          (assume Heq : a₁ = a₂, inl (Heq ▸ rfl))
          (assume Hne : a₁ ≠ a₂, inr (assume Hn : some a₁ = some a₂, absurd (equal Hn) Hne))))
end option
