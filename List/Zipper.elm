module List.Zipper exposing
  ( Zipper(..)
  , fromList
  , before
  , get
  , after
  , toList
  , updateBefore
  , update
  , updateAfter
  , first
  , previous
  , next
  , last
  , find
  )

{-| A zipper for `List`.

# The `Zipper` type
@docs Zipper

# Constructing a `Zipper`
@docs fromList

# Accessors
@docs before, get, after, toList

# Updating
@docs updateBefore, update, updateAfter

# Moving around
@docs first, previous, next, last, find

-}

import List exposing (reverse)

{-| The `Zipper` type. -}
type Zipper a = Zipper (List a) a (List a)

{-| Construct a `Zipper` from a list. The `Zipper` will focus on the first element (if there is a first element). -}
fromList : List a -> Maybe (Zipper a)
fromList xs = 
  case xs of
    [] -> Nothing
    y :: ys -> Just (Zipper [] y ys)

{-| Returns all elements before the element the `Zipper` is focussed on. -}
before : Zipper a -> List a
before (Zipper ls _ _) = reverse ls

{-| Returns the element the `Zipper` is focussed on. -}
get : Zipper a -> a
get (Zipper _ x _) = x

{-| Returns all elements after the element the `Zipper` is focussed on -}
after : Zipper a -> List a
after (Zipper _ _ rs) = rs

{-| Reconstruct the list. -}
toList : Zipper a -> List a
toList z = before z ++ [get z] ++ after z

{-| Update all elements before the element the `Zipper` is focussed on. -}
updateBefore : (List a -> List a) -> Zipper a -> Zipper a
updateBefore f ((Zipper _ x rs) as zipper) =
  let
    elementsBefore = before zipper
    updatedElementsBefore = f elementsBefore
  in
    Zipper (reverse updatedElementsBefore) x rs
    
{-| Updat the element the `Zipper` is focussed on. -}
update : (a -> a) -> Zipper a -> Zipper a
update f (Zipper ls x rs) = 
  Zipper ls (f x) rs
  
{-| Update all elements after the element the `Zipper` is focussed on. -}
updateAfter : (List a -> List a) -> Zipper a -> Zipper a
updateAfter f (Zipper ls x rs) =
  Zipper ls x (f rs)
  
{-| Move the focus to the first element of the list. -}
first : Zipper a -> Zipper a
first ((Zipper ls x rs) as zipper) =
  case reverse ls of
    [] -> zipper
    y :: ys -> Zipper [] y (ys ++ [x] ++ rs)
    
{-| Move the focus to the element before the element the `Zipper` is currently focussed on (if there is such an element). -}
previous : Zipper a -> Maybe (Zipper a)
previous (Zipper ls x rs) =
  case ls of
    [] -> Nothing
    y :: ys -> Just <| Zipper ys y (x :: rs)
      
{-| Move the focus to the element after the element the `Zipper` is currently focussed on (if there is such an element). -}
next : Zipper a -> Maybe (Zipper a)
next (Zipper ls x rs) =
  case rs of
    [] -> Nothing
    y :: ys -> Just <| Zipper (x :: ls) y ys
    
{-| Move the focus to the last element of the list. -}
last : Zipper a -> Zipper a
last ((Zipper ls x rs) as zipper) =
  case reverse rs of
    [] -> zipper
    y :: ys -> Zipper (ys ++ [x] ++ ls) y [] 
    
{-| Returns a `Zipper` focussed on the first element for which the predicate returns `True` (starting from a given `Zipper`). -}
find : (a -> Bool) -> Zipper a -> Maybe (Zipper a)
find predicate ((Zipper ls x rs) as zipper) =
  if predicate x then
    Just zipper
  else
    case next zipper of
      Just nextZipper ->
        find predicate nextZipper
        
      Nothing ->
        Nothing
