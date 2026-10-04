(* Latte generated F* view *)
module AnalysisSoundness

#push-options "--no_tactics"
open While

open ReachingDefinitions

open InstrumentedSemantics

type definitions_subset (left: definition_set) (right: definition_set) = (name: variable) -> (source: origin) -> left name source -> right name source

let covers_under_subset (left: definition_set) (right: definition_set) (last: last_writer) (included: definitions_subset left right) (covered: covers left last) : covers right last =
  fun name -> ((included name) (last name)) (covered name)

let definitions_subset_reflexive (definitions: definition_set) : definitions_subset definitions definitions =
  fun _name -> fun _source -> fun present -> present

let union_includes_left (left: definition_set) (right: definition_set) : definitions_subset left (definitions_union left right) =
  fun _name -> fun _source -> fun present -> Left present

let union_includes_right (left: definition_set) (right: definition_set) : definitions_subset right (definitions_union left right) =
  fun _name -> fun _source -> fun present -> Right present

noeq type reaching_analysis : (program: statement) -> (before: definition_set) -> (after: definition_set) -> Type =
| AnalysisAssign: mark: label -> name: variable -> value: arithmetic_expression -> before: definition_set -> reaching_analysis (Assign mark name value) before (definitions_assign before name mark)
| AnalysisSkip: mark: label -> definitions: definition_set -> reaching_analysis (Skip mark) definitions definitions
| AnalysisSequence: first: statement -> second: statement -> before: definition_set -> middle: definition_set -> after: definition_set -> first_analysis: reaching_analysis first before middle -> second_analysis: reaching_analysis second middle after -> reaching_analysis (Sequence first second) before after
| AnalysisIf: mark: label -> guard: boolean_expression -> yes: statement -> no: statement -> before: definition_set -> yes_after: definition_set -> no_after: definition_set -> yes_analysis: reaching_analysis yes before yes_after -> no_analysis: reaching_analysis no before no_after -> reaching_analysis (If mark guard yes no) before (definitions_union yes_after no_after)
| AnalysisWhile: mark: label -> guard: boolean_expression -> body: statement -> before: definition_set -> head: definition_set -> body_after: definition_set -> entry_to_head: definitions_subset before head -> body_analysis: reaching_analysis body head body_after -> back_to_head: definitions_subset body_after head -> reaching_analysis (While mark guard body) before head

let rec analysis_sound (program: statement) (before_definitions: definition_set) (after_definitions: definition_set) (analysis: reaching_analysis program before_definitions after_definitions) (before_state: state) (before_writer: last_writer) (after_state: state) (after_writer: last_writer) (execution: instrumented_big_step program before_state before_writer after_state after_writer) (covered: covers before_definitions before_writer) : Tot (covers after_definitions after_writer) (decreases execution) =
  match analysis with | AnalysisAssign mark name _value before -> begin match execution with | InstrumentedAssign _execution_mark _execution_name _execution_value _current _writers -> begin assignment_sound before before_writer covered name mark end end | AnalysisSkip _mark _definitions -> begin match execution with | InstrumentedSkip _execution_mark _current _writers -> begin covered end end | AnalysisSequence first second before middle after first_analysis second_analysis -> begin match execution with | InstrumentedSequence _execution_first _execution_second first_before_state first_before_writer middle_state middle_writer second_after_state second_after_writer first_step second_step -> begin analysis_sound second middle after second_analysis middle_state middle_writer second_after_state second_after_writer second_step (analysis_sound first before middle first_analysis first_before_state first_before_writer middle_state middle_writer first_step covered) end end | AnalysisIf mark guard yes no before yes_after no_after yes_analysis no_analysis -> begin match execution with | InstrumentedIfTrue _execution_mark _execution_guard _execution_yes _execution_no branch_before_state branch_before_writer branch_after_state branch_after_writer _guard_true branch -> begin covers_under_subset yes_after (definitions_union yes_after no_after) branch_after_writer (union_includes_left yes_after no_after) (analysis_sound yes before yes_after yes_analysis branch_before_state branch_before_writer branch_after_state branch_after_writer branch covered) end | InstrumentedIfFalse _execution_mark _execution_guard _execution_yes _execution_no branch_before_state branch_before_writer branch_after_state branch_after_writer _guard_false branch -> begin covers_under_subset no_after (definitions_union yes_after no_after) branch_after_writer (union_includes_right yes_after no_after) (analysis_sound no before no_after no_analysis branch_before_state branch_before_writer branch_after_state branch_after_writer branch covered) end end | AnalysisWhile mark guard body before head body_after entry_to_head body_analysis back_to_head -> begin match execution with | InstrumentedWhileFalse _execution_mark _execution_guard _execution_body _loop_state loop_writer _guard_false -> begin covers_under_subset before head loop_writer entry_to_head covered end | InstrumentedWhileTrue _execution_mark _execution_guard _execution_body loop_before_state loop_before_writer middle_state middle_writer loop_after_state loop_after_writer _guard_true body_step rest_step -> begin analysis_sound (While mark guard body) head head (AnalysisWhile mark guard body head head body_after (definitions_subset_reflexive head) body_analysis back_to_head) middle_state middle_writer loop_after_state loop_after_writer rest_step (covers_under_subset body_after head middle_writer back_to_head (analysis_sound body head body_after body_analysis loop_before_state loop_before_writer middle_state middle_writer body_step (covers_under_subset before head loop_before_writer entry_to_head covered))) end end
#pop-options