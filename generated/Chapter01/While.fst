(* Latte generated F* view *)
module While

#push-options "--no_tactics"
type label = nat

type variable =
| X: variable
| Y: variable
| Z: variable

type arithmetic_operator =
| Add: arithmetic_operator
| Subtract: arithmetic_operator
| Multiply: arithmetic_operator

type relation_operator =
| Equal: relation_operator
| Less: relation_operator
| LessEqual: relation_operator

noeq type arithmetic_expression =
| Variable: name: variable -> arithmetic_expression
| Integer: value: int -> arithmetic_expression
| Arithmetic: operation: arithmetic_operator -> left: arithmetic_expression -> right: arithmetic_expression -> arithmetic_expression

noeq type boolean_expression =
| True: boolean_expression
| False: boolean_expression
| Not: body: boolean_expression -> boolean_expression
| And: left: boolean_expression -> right: boolean_expression -> boolean_expression
| Relation: operation: relation_operator -> left: arithmetic_expression -> right: arithmetic_expression -> boolean_expression

noeq type statement =
| Assign: mark: label -> name: variable -> value: arithmetic_expression -> statement
| Skip: mark: label -> statement
| Sequence: first: statement -> second: statement -> statement
| If: mark: label -> guard: boolean_expression -> yes: statement -> no: statement -> statement
| While: mark: label -> guard: boolean_expression -> body: statement -> statement

type state = variable -> int

let write (current: state) (written: variable) (value: int) : state =
  fun queried -> if queried = written then
    begin value end
  else
    begin current queried end

let apply_arithmetic (operation: arithmetic_operator) (left: int) (right: int) : int =
  match operation with | Add -> begin left + right end | Subtract -> begin left - right end | Multiply -> begin left * right end

let rec evaluate_arithmetic (expression: arithmetic_expression) (current: state) : Tot int (decreases expression) =
  match expression with | Variable name -> begin current name end | Integer value -> begin value end | Arithmetic operation left right -> begin apply_arithmetic operation (evaluate_arithmetic left current) (evaluate_arithmetic right current) end

let apply_relation (operation: relation_operator) (left: int) (right: int) : bool =
  match operation with | Equal -> begin left = right end | Less -> begin left < right end | LessEqual -> begin left <= right end

let rec evaluate_boolean (expression: boolean_expression) (current: state) : Tot bool (decreases expression) =
  match expression with | True -> begin true end | False -> begin false end | Not body -> begin not (evaluate_boolean body current) end | And left right -> begin evaluate_boolean left current && evaluate_boolean right current end | Relation operation left right -> begin apply_relation operation (evaluate_arithmetic left current) (evaluate_arithmetic right current) end

noeq type equality (#a: Type) : (left: a) -> (right: a) -> Type =
| Reflexive: value: a -> equality value value

noeq type big_step : (program: statement) -> (before: state) -> (after: state) -> Type =
| BigStepAssign: mark: label -> name: variable -> value: arithmetic_expression -> current: state -> big_step (Assign mark name value) current (write current name (evaluate_arithmetic value current))
| BigStepSkip: mark: label -> current: state -> big_step (Skip mark) current current
| BigStepSequence: first: statement -> second: statement -> before: state -> middle: state -> after: state -> first_step: big_step first before middle -> second_step: big_step second middle after -> big_step (Sequence first second) before after
| BigStepIfTrue: mark: label -> guard: boolean_expression -> yes: statement -> no: statement -> before: state -> after: state -> guard_true: equality (evaluate_boolean guard before) true -> branch: big_step yes before after -> big_step (If mark guard yes no) before after
| BigStepIfFalse: mark: label -> guard: boolean_expression -> yes: statement -> no: statement -> before: state -> after: state -> guard_false: equality (evaluate_boolean guard before) false -> branch: big_step no before after -> big_step (If mark guard yes no) before after
| BigStepWhileFalse: mark: label -> guard: boolean_expression -> body: statement -> before: state -> guard_false: equality (evaluate_boolean guard before) false -> big_step (While mark guard body) before before
| BigStepWhileTrue: mark: label -> guard: boolean_expression -> body: statement -> before: state -> middle: state -> after: state -> guard_true: equality (evaluate_boolean guard before) true -> body_step: big_step body before middle -> rest_step: big_step (While mark guard body) middle after -> big_step (While mark guard body) before after

let reaching_example = Sequence (Assign 1 Y (Variable X)) (Sequence (Assign 2 Z (Integer 1)) (Sequence (While 3 (Relation Less (Integer 0) (Variable Y)) (Sequence (Assign 4 Z (Arithmetic Multiply (Variable Z) (Variable Y))) (Assign 5 Y (Arithmetic Subtract (Variable Y) (Integer 1))))) (Assign 6 Y (Integer 0))))
#pop-options