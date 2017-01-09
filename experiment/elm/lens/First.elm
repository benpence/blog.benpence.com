import Task exposing ( Task )

import                          Task

type alias Lens s a = (a -> a) -> s -> s

const : a -> b -> a
const value _ = value

set : Lens s a -> a -> s -> s
set lens value obj = lens (const value) obj

view : Lens s a -> s -> a
view lens obj = lens (identity) obj 

overT : Lens s a -> (a -> Task e a) -> s -> Task e s
overT lens trans obj = Task.map (set obj << get obj) (trans obj) 

type alias Person =
  { name : String
  }
type alias Family =
  { members : List Person
  }
type alias Community =
  { families : List Family
  }
                      
personName : Lens Person String
personName trans person = { person | name = trans person.name }

familyMembers : Lens Family (List Person)
familyMembers trans family = { family | members = trans family.members }

communityFamilies : Lens Community (List Family)
communityFamilies trans community = { community | families = trans community.families }
