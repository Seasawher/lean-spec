/-
# General Purpose Functions

This module defines generic functions and types. The nature of the definitions is such that
they could reasonably appear in the Lean standard library at a future date. Items are
included only if needed in support of the examples in the tutorial.

The focus of this tutorial is specification, not proof or implementation. Most instances
where a proof is required are left as `sorry`.
-/
import Std.Data.AssocList

/-
## Restricted Basic Types

Length constrained strings.
-/

def Str (m n : Nat) := { s : String // m ≤ s.length ∧ s.length ≤ n }

instance : DecidableEq (Str m n) :=
  sorry

/-
Non-zero natural numbers.
-/
def Nat₁ := { n : Nat // n ≠ 0 }

/-
Range restricted natural numbers.
-/
def NatMN (m n : Nat) := { x : Nat // m ≤ x ∧ x < n }

/-
Non-negative floats.
-/
def Float₀ := { x : Float // x ≥ 0 }

/-
Range restricted floats.
-/
def FloatMN (m n : Float) := { x : Float // m ≤ x ∧ x < n }

/-
## List
-/
namespace List 

/-
The number of occurrences of an element in a list.
-/
def numOccurs [BEq α] (a : α) : List α → Nat
  | []    => 0
  | b::as => if a == b then numOccurs a as + 1 else numOccurs a as

/-
The sum of the elements of a list. The base type must be an instance of `Add`, and the identity is provided as an argument.
-/
def add [Add α] (as : List α) : α → α :=
  as.foldr (· + ·)

/-
The product of the elements of a list. The base type must be an instance of `Mul`, and the identity is provided as an argument.
-/
def mul [Mul α] (as : List α) : α → α :=
  as.foldr (· * ·)

/-
Set equality relation on lists: same elements regardless of order or multiplicity.
-/
def seteq (as bs : List α) :=
  ∀ a : α, a ∈ as ↔ a ∈ bs

/-
Are the elements of a list in ascending order?
-/
def ascending [LE α] : List α → Prop
 | [] | [_] => True
 | a::b::as => a ≤ b ∧ ascending (b::as)

/-
Are the elements of a list in strict ascending order?
-/
def ascendingStrict [LT α] : List α → Prop
 | [] | [_] => True
 | a::b::as => a < b ∧ ascendingStrict (b::as)

/-
Are the elements of a list in descending order?
-/
def descending [LE α] : List α → Prop
 | [] | [_] => True
 | a::b::as => a ≥ b ∧ ascending (b::as)

/-
Are the elements of a list in strict descending order?
-/
def descendingStrict [LT α] : List α → Prop
 | [] | [_] => True
 | a::b::as => a > b ∧ descendingStrict (b::as)

/-
The values contained in a list of optional items.
-/
def somes : List (Option α) → List α
  | []           => []
  | none :: as   => somes as
  | some a :: as => a :: somes as

/-
The list of consecutive pairs drawn from a source list.
-/
def consecutivePairs : List α → List (α × α)
  | [] | [_] => []
  | a :: b :: as => (a,b) :: consecutivePairs (b :: as)

end List

/-
## Sum
-/
namespace Sum

/-
Is a left injection.
-/
def isl : α ⊕ β → Bool
  | inl _ => true
  | inr _ => false

/-
Is a right injection.
-/
def isr : α ⊕ β → Bool
  | inl _ => false
  | inr _ => true

end Sum

/-
## AssocList

Elements of type `AssocList` are lists whose elements are key/value pairs.
`AssocList` is defined in [std4](https://github.com/leanprover/std4).
-/
namespace Std.AssocList

/-
The domain of an `AssocList` is the list of the first elements in the pairs.
-/
def domain (al : AssocList α β) : List α :=
  al.toList.map (·.fst)

/-
The range of an `AssocList` is the list of the second elements in the pairs.
-/
def range (al : AssocList α β) : List β :=
   al.toList.map (·.snd)

/-
An `AssocList` is a finite map if there are no duplicate elements in its domain.
-/
def isMap [BEq α] (al : AssocList α β) : Bool :=
  let dom := al.domain
  dom.length = dom.eraseDups.length

/-
Find the value associated with a key, knowing the key is in the list.
-/
def find [BEq α] (a : α) (al : AssocList α β) (h : al.contains a) :  β :=
  sorry

/-
Find the entry (key and value) associated with a key, knowing the key is in the list.
-/
def findEntry [BEq α] (a : α) (al : AssocList α β) (h : al.contains a) : α × β :=
  sorry

/-
Filter an association list by a predicate on the key.
-/
def filter [BEq α] (p : α → Bool) : AssocList α β → AssocList α β
  | nil          => nil
  | cons a b abs => if p a then cons a b (abs.filter p) else abs.filter p

end Std.AssocList

/-
## Map

Definition of a type of finite maps.

Map is defined in terms of association lists in which keys are associated with
only one value.
-/
namespace Std

/-
A `Map` is an `AssocList` whose domain contains no duplicates.
-/
def Map α β [BEq α] := { al : AssocList α β // al.isMap }

/-
Infix operator for finite maps. Precedence just lower than `×`.
-/
infixr:34 " ⟹ "  => Map

instance [BEq α] : EmptyCollection (α ⟹ β) where
  emptyCollection := ⟨∅, rfl⟩

/-
Many of the functions are `Map` versions of the corresponding `AssocList` functions.

Question: could some of these definitions be avoided through coercion?
-/
namespace Map

/-
Does a map contain a key?
-/
def contains [BEq α] (a : α) (m : α ⟹ β) : Bool :=
  m.val.contains a 

/-
Remove an entry with a key from a map.
-/
def erase [BEq α] (m : α ⟹ β) (a : α) : α ⟹ β :=
  ⟨m.val.erase a, sorry⟩

/-
Add an item to a map.
-/
def add [BEq α] (m : α ⟹ β) (a : α) (b : β) : α ⟹ β :=
  ⟨(m.erase a).val.cons a b, sorry⟩

/-
Find the entry (key and value) associated with a key, if in the map.
-/
def findEntry? [BEq α] (a : α) (m : α ⟹ β) : Option (α × β) :=
  m.val.findEntry? a 

/-
Find the entry (key and value) associated with a key, knowing the key is in the map.
-/
def findEntry [BEq α] (a : α) (m : α ⟹ β) (h : m.contains a) : α × β :=
  m.val.findEntry a h

/-
Find the value associated with a key, if the key is in the map.
-/
def find? [BEq α] (a : α) (m : α ⟹ β) : Option β :=
  m.val.find? a 

/-
Find the value associated with a key, knowing the key is in the map.
-/
def find [BEq α] (a : α) (m : α ⟹ β) (h : m.contains a) :  β :=
  (m.findEntry a h).2

/-
`Map` is an instance of `Membership`, allowing notation `entry ∈ map`.
Note membership is based on the full entry, not just the key.
-/
instance [BEq α] : Membership (α × β) (α ⟹ β)  where
  mem ab m := (m.findEntry? ab.1).isSome

/-
The list of pairs extracted from a map.
-/
def toList [BEq α] (m : α ⟹ β) : List (α × β) :=
  m.val.toList

/-
Is a map empty?
-/
def isEmpty [BEq α] (m : α ⟹ β) : Bool :=
  m.val.isEmpty

/-
Filter a map by a predicate on the key.
-/
def filter [BEq α] (p : α → Bool) (m : α ⟹ β) : α ⟹ β :=
  ⟨m.val.filter p, sorry⟩

/-
The domain of a finite map: guaranteed to contain no duplicates.
-/
def domain {α: Type} [BEq α] (m : α ⟹ β) : List α :=
  m.val.domain

/-
The range of a finite map.
-/
def range [BEq α] (m : α ⟹ β) : List β :=
  m.val.range 

end Map

end Std