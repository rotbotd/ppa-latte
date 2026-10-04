(* Latte generated F* view *)
module ReachingDefinitions

#push-options "--no_tactics"
open While

noeq type impossible =


noeq type both (a: Type) (b: Type) =
| Both: first: a -> second: b -> both a b

noeq type either (a: Type) (b: Type) =
| Left: value: a -> either a b
| Right: value: b -> either a b

type origin =
| Entry: origin
| At: mark: label -> origin

type definition_set = (name: variable) -> (source: origin) -> Type

let definitions_empty (_name: variable) (_source: origin) : Type =
  impossible

let definitions_union (left: definition_set) (right: definition_set) (name: variable) (source: origin) : Type =
  either (left name source) (right name source)

let definitions_entry (_name: variable) (source: origin) : Type =
  equality source Entry

noeq type different : (left: variable) -> (right: variable) -> Type =
| DifferentXY: different X Y
| DifferentXZ: different X Z
| DifferentYX: different Y X
| DifferentYZ: different Y Z
| DifferentZX: different Z X
| DifferentZY: different Z Y

let definitions_kill (written: variable) (definitions: definition_set) (name: variable) (source: origin) : Type =
  both (different name written) (definitions name source)

let definitions_gen (written: variable) (mark: label) (name: variable) (source: origin) : Type =
  both (equality name written) (equality source (At mark))

let definitions_assign (definitions: definition_set) (written: variable) (mark: label) (name: variable) (source: origin) : Type =
  definitions_union (definitions_kill written definitions) (definitions_gen written mark) name source

type last_writer = (name: variable) -> origin

let last_writer_entry (_name: variable) : origin =
  Entry

let last_writer_write (previous: last_writer) (written: variable) (mark: label) : last_writer =
  fun name -> if name = written then
    begin At mark end
  else
    begin previous name end

type covers (definitions: definition_set) (last: last_writer) = (name: variable) -> definitions name (last name)

let entry_covers () : covers definitions_entry last_writer_entry =
  fun _name -> Reflexive Entry

noeq type variable_comparison : (left: variable) -> (right: variable) -> Type =
| VariablesSame: value: variable -> variable_comparison value value
| VariablesDifferent: left: variable -> right: variable -> evidence: different left right -> variable_comparison left right

let compare_variables (left: variable) (right: variable) : variable_comparison left right =
  match left with | X -> begin match right with | X -> begin VariablesSame X end | Y -> begin VariablesDifferent X Y DifferentXY end | Z -> begin VariablesDifferent X Z DifferentXZ end end | Y -> begin match right with | X -> begin VariablesDifferent Y X DifferentYX end | Y -> begin VariablesSame Y end | Z -> begin VariablesDifferent Y Z DifferentYZ end end | Z -> begin match right with | X -> begin VariablesDifferent Z X DifferentZX end | Y -> begin VariablesDifferent Z Y DifferentZY end | Z -> begin VariablesSame Z end end

let assignment_sound (definitions: definition_set) (last: last_writer) (covered: covers definitions last) (written: variable) (mark: label) : covers (definitions_assign definitions written mark) (last_writer_write last written mark) =
  fun name -> match compare_variables name written with | VariablesSame value -> begin Right (Both (Reflexive value) (Reflexive (At mark))) end | VariablesDifferent left right evidence -> begin Left (Both evidence (covered left)) end

let generated_present (definitions: definition_set) (written: variable) (mark: label) : definitions_assign definitions written mark written (At mark) =
  Right (Both (Reflexive written) (Reflexive (At mark)))

let other_preserved (definitions: definition_set) (written: variable) (other: variable) (mark: label) (source: origin) (distinct: different other written) (present: definitions other source) : definitions_assign definitions written mark other source =
  Left (Both distinct present)
#pop-options