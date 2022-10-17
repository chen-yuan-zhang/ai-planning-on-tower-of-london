(in-package "CL-USER")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;         name:  4caps
;;;;      version:  1.2
;;;;         date:  8.2002
;;;;       purpose: implements the 4caps cognitive architecture
;;;;
;;;;       author:  sashank varma
;;;;        email:  sashank@vuse.vanderbilt.edu
;;;; organization:  center for cognitive brain imaging
;;;;                carnegie mellon university
;;;;
;;;;        usage:  load this file into an ansi common lisp environment.  has
;;;;                been tested in macintosh common lisp (v3.0 or higher) and
;;;;                allegro common lisp (v6.2 or higher).
;;;;
;;;; history:
;;;;
;;;;   12.1994 sv: (v0.1) the basic interpreter and user interface,
;;;;                 defwmclass [1], discrete rhs actions, and the matches
;;;;                 command.  the motivation behind the new architecture and
;;;;                 its implementation details are given in "CS360 Project:
;;;;                 The Simple Production System Interpreter"[2].
;;;;
;;;;                 [1] this refers to the original and traditional naming
;;;;                     of declarative memory as working memory.
;;;;                 [2] the architecture has had several names in its life.
;;;;                     it started as the "simple production system
;;;;                     interpreter but was quickly changed (in response to
;;;;                     a suggestion by mike byrne(*), if my memory serves
;;;;                     correctly, to the "object-oriented production system
;;;;                     interpreter" because it yielded a good acronym:
;;;;                     oopsi.  once development merged with efforts at
;;;;                     carnegie mellon, it was renamed to 4capsto reflect
;;;;                     its intellectual lineage.
;;;;
;;;;                 (*) mike byrne did his undergraduate work at michigan
;;;;                     under dave kieras working on hci and production
;;;;                     system models of cognition.  as a graduate student
;;;;                     at georgia tech, he followed up on his interest in
;;;;                     3caps (he almost attended cmu for graduate school to
;;;;                     work with marcel just) by visiting sashank varma at
;;;;                     vanderbilt.  there, he saw the decstation 10 on which
;;;;                     the original franzlisp version of 3caps ran.  (it was
;;;;                     called caps89 at the time.)  when varma ported caps89
;;;;                     to common lisp shortly thereafter, byrne obtained a
;;;;                     copy.  he applied it to hci, producing several
;;;;                     conference papers and a master thesis (under the
;;;;                     direction of susan bovair) that eventually surfaced
;;;;                     as a cognitive science paper.  he developed his own
;;;;                     architecture for his dissertation that substituted
;;;;                     notions of decay and, following tim salthouse's work,
;;;;                     processing speed for the capacity-constrained working
;;;;                     memory of 3caps.  he used this architecture, called
;;;;                     SPAN, to model several effects of aging.  this work
;;;;                     has since made its way into the cognitive aging
;;;;                     literature.  byrne found time to scratch his cmu
;;;;                     bug, joining john anderson's act-r group for a post
;;;;                     doc.  he continued to pursue research at the boundary
;;;;                     of production systems, working memory, and hci.  he
;;;;                     developed act-r/pm, which augments act-r with
;;;;                     perceptual and motor capabilities modeled after those
;;;;                     of epic.  epic was developed by dave kieras (remember
;;;;                     him?) and dave meyer.  (both are faculty at michigan
;;;;                     and were graduate students there three decades ago.
;;;;                     in addition, kieras was a post doc under just and
;;;;                     carpenter two decades ago.)  across two psych review
;;;;                     papers, the two daves applied epic to model old and
;;;;                     new data concerning the psychological refractory
;;;;                     period (prp).  their major claim, instantiated in an
;;;;                     epic model, was that the central processor is
;;;;                     parallel and capacity-free, and that the prp arises
;;;;                     not from central bottlenecks but limitations of
;;;;                     perceptual and motor processing.  in act-r/pm, mike
;;;;                     took on his zeusian father.  he modeled the existing
;;;;                     prp data and collected new data.  because the model
;;;;                     was written in act-r, it assumes a serial central
;;;;                     processor with capacity limitations.  that is, it
;;;;                     stands in contrast to epic.  his model was able to
;;;;                     fit the data that epic handled as well as his new
;;;;                     data, which suggested that epic's view of central
;;;;                     cognition is wrong.  this work is in press in psych
;;;;                     review.  mike is now an assistant professor at rice
;;;;                     university. 
;;;;
;;;;   06.1995 sv: added restart detection.  a problem faced by all production
;;;;                 system interpreters and their models is what to do when
;;;;                 no productions match.  caps and 3caps handled this by
;;;;                 invoking a fake "restart" production which inserted into
;;;;                 declarative memory a bare element (restart).  this could
;;;;                 be matched by legitimate model productions that would
;;;;                 initiate the next epoch of processing. restarts are
;;;;                 signaled through a global variable that may be directly
;;;;                 tested by the lhss of productions.
;;;;
;;;;   04.1997 sv: (v0.2) added the compiler.[3]
;;;;
;;;;                 [3] for the next few years, 4caps permitted mixed-mode
;;;;                     execution of models such that some of the productions
;;;;                     could be interpreted and others compiled.  while this
;;;;                     was aesthetically pleasing, it was eventually found
;;;;                     to be superfluous because nothing was gained by
;;;;                     interpreting a production except slowdown of two
;;;;                     orders of magnitude.  furthermore, supporting this
;;;;                     duality introduced extra bookkeeping to ensure that
;;;;                     the interpreter and compiler implemented identical
;;;;                     semantics.  for these reasons, the interpreter was
;;;;                     eventually deprecated and then excised.
;;;;
;;;;   05.1997 sv: (v0.3) created during a three-week stay in pittsburgh to
;;;;                 explore the fruitfulness of merging sashank varma's work
;;;;                 at vanderbilt and marcel just's and pat carpenter's work
;;;;                 at cmu.  the main result was the ability to define
;;;;                 multiple, collaborating production systems, called
;;;;                 modules[4,6].  for example, one could execute 10 instances
;;;;                 of a tower of hanoi model simultaneously.  of more
;;;;                 relevance was the fact that lhs predicates could be
;;;;                 declared to be implemented by another production system.
;;;;                 when executing such a predicate in service of matching
;;;;                 its production, its arguments would be passed to the
;;;;                 implementational production system and it would be run
;;;;                 in-line.  it would return the value of the predicate,
;;;;                 and matching in the original production system would
;;;;                 continue.[5]
;;;;
;;;;                 [4] modules would come to be renamed "components" as the
;;;;                     architecture matured, as described in the entry dated
;;;;                     03.2001.
;;;;                 [5] this hierarchical scheme of interaction between
;;;;                     production systems would eventually be abandoned, as
;;;;                     described in the entry for 08.1999.
;;;;                 [6] components would come to be renamed "centers" during
;;;;                     the revision of the "Theory Paper" submitted to
;;;;                     Psychological Reviewm, s described in the entry dated
;;;;                     08.2002.
;;;;
;;;;   09.1997 sv: added negative ces, which are also known as absence tests.
;;;;                 this was crucial for achieving expressiveness equal to
;;;;                 other production system interpreters (e.g., ops5, soar,
;;;;                 and act).
;;;;
;;;;   10.1997 sv: added state saving to the matcher, which already
;;;;                 implemented node sharing.  state saving means that all
;;;;                 dmes are not matched against all production on each
;;;;                 macrocycle.  rather, on each macrocycle, the changes in
;;;;                 declarative memory, which typically amount to a few dmes
;;;;                 added and subtracted, are used by the matcher to compute
;;;;                 changes to the conflict set of instantiations.  node
;;;;                 sharing is the recognition that productions share a lot
;;;;                 of predicate structure.  if each node of the rete network
;;;;                 implements one predicate, then productions with
;;;;                 overlapping lhss can share nodes.  in this case, the
;;;;                 predicate evaluation need only occur once.  with the
;;;;                 inclusion of state saving and node sharing, the matcher
;;;;                 implements the two major optimizations of rete networks.
;;;;
;;;;   01.1998 sv: added activations to dmes.  that is, each dme has an act
;;;;                 slot that records this scalar quantity.  this brings the
;;;;                 architecture firmly into the *caps family.
;;;;
;;;;   02.1998 sv: (v0.4) standardized the notion of time.  each production
;;;;                 system keeps its own cycle count for those times on which
;;;;                 it fired instantiations.  each production system is
;;;;                 coordinated in a global recognize-act loop.  each
;;;;                 execution of this loop is called a macrocycle.  it
;;;;                 involves parallel matching of each production system and,
;;;;                 of those that generate instantiations, the parallel
;;;;                 firing of all instantiations (subject to capacity
;;;;                 considerations) and incrementing of the local cycle
;;;;                 count.
;;;;
;;;;   06.1998 sv: changed the representation of ce-nodes in accord with a
;;;;                 suggestion made by brian milnes years ago(*).  in a
;;;;                 capacity-constrained environment, the activation level of
;;;;                 each dme can change on each macrocycle through resource
;;;;                 shortfalls and scaling back.  this effectively nullifies
;;;;                 the assumption of the state saving optimization because
;;;;                 it assumes that only a few dmes change (i.e., are added,
;;;;                 deleted, or modified) for each unit of time.  (for more
;;;;                 on state saving, see the entry for 10.1997 above.)
;;;;                 however, we can regain most of the benefits of state
;;;;                 saving even as the activations of many dmes fluctuate
;;;;                 from macrocycle to macrocycle by noting that only when
;;;;                 a dme's activation changes sufficiently that it crosses
;;;;                 a threshold somewhere must it be rematched -- and only
;;;;                 for that threshold.
;;;;
;;;;                 (*) brian milnes was sashank varma's ta for 15-212
;;;;                     fundamental structures of computer science II while
;;;;                     at cmu.  the central project of this class was to
;;;;                     write portions of a rete matcher.  milnes is a rete
;;;;                     expert, and has lent his expertise to the soar group
;;;;                     on numerous occasions.  he is also facile with the
;;;;                     functional programming language ml and the formal
;;;;                     specification language z.  when porting 3caps from
;;;;                     franzlisp to common lisp, brian made this suggestion.
;;;;                     (it was not implemented at that time, however.)
;;;;                     milnes is off pursuing dotcom riches, perhaps at
;;;;                     lycos.com or perhaps at ac nielsen's eratings.com.
;;;;
;;;;   11.1998 sv: (v0.5) elevated the spew rhs action to central status,
;;;;                 eliminating all of the discrete rhs actions except
;;;;                 modify, which is deprecated but is a necessary evil along
;;;;                 the lines of goto in conventional programming languages.
;;;;                 my advice is to only use it in support code while
;;;;                 modifying support dmes.
;;;;
;;;;   03.1999 sv: (v0.6) systematized the production compiler and the
;;;;                 structure of lhss.  lhs predicates fall into six classes.
;;;;                 *dynamic wraps conventional, functional predicates that
;;;;                 must be performed on every macrocycle (modulo skipping
;;;;                 licensed by the rete algorithm).  *static wraps tests
;;;;                 that need only be performed once, at compile time.
;;;;                 *always wraps tests that must be performed on each
;;;;                 macrocycle, i.e., that cannot be skipped by the rete
;;;;                 algorithm.  this is typically for tests that rely on lisp
;;;;                 variables that can be changed by the user "out from
;;;;                 under" the rete algorithm,  it is also used for tests that
;;;;                 query the activation levels of dmes, which also
;;;;                 circumvents that rete algorithm.  *whole wraps tests that
;;;;                 should not be decomposed further in the rete algorithm's
;;;;                 standard quest for node sharing.  *no wraps absence
;;;;                 tests.  finally, the and combinator combines top-level
;;;;                 lhs predicates into a single conjunction.
;;;;
;;;;   08.1999 sv: (v0.7.1) uses the simplex algorithm to dynamically allocate
;;;;                 activation from centers to dmes based on center
;;;;                 capacities, dme activation requests as computed by the
;;;;                 productions, and the specializations of each center
;;;;                 for each dm class[6].  required a ton of infrastructure.
;;;;                 the simplex algorithm was borrowed.  a top-level command
;;;;                 for defining specializations for (center, dm-class)
;;;;                 pairs was written.  the main recognize-act loop was
;;;;                 re-organized to sandwich a call to simplex to adjudicate
;;;;                 what centers handle what proportions of what dm
;;;;                 classes.
;;;;
;;;;                 [6] the allocation problem facing 4caps is translated
;;;;                     into a linear programming (lp) problem and solved via
;;;;                     the simplex algorithm.  a linear programming problem
;;;;                     consists of a number of variables to be assigned
;;;;                     nonnegative values in such a way as to maximize a
;;;;                     linear combination of these values while satisfying
;;;;                     linear constraints in them.  there are two sets of
;;;;                     constraints.  the first ensures that no center
;;;;                     allocates more than its capacity.  the second ensures
;;;;                     that each activation request comes as close as
;;;;                     possible to being satisfied.  there is a request for
;;;;                     each dme that states its target activation level
;;;;                     given its level before the macrocycle began and the
;;;;                     sum of the activation directed to it by production
;;;;                     firings in various centers.  there is a variable
;;;;                     for each center that has a numeric specialization
;;;;                     for, and thus may possibly contribute activation to
;;;;                     each dme.  the value simplex assigns it represents
;;;;                     that center's contribution to that dme.
;;;;
;;;;   09.1999 sv: (v0.7.2) added the history function to verbosely display
;;;;                 the pattern of activation allocations during simulations.
;;;;
;;;;   10.1999 sv: (v0.7.3) further improvements to the incorporation of
;;;;                 simplex.  instead of storing the specialization of each
;;;;                 center for each dm class in a table, define multi-
;;;;                 methods for each (dm class, center) pair that return
;;;;                 this information.  this allows the effortless inheritance
;;;;                 of specializations by descendant classes from ancestor
;;;;                 classes.  perhaps more importantly, changed the spew
;;;;                 rhs action, removing the "in" clause which had specified
;;;;                 which centers contributed what levels of activation to
;;;;                 the target element.  spews now just specify the amount of
;;;;                 activation to be spewed; the simplex algorithm determines
;;;;                 which centers supply what portions of this request.
;;;;
;;;;   10.1999 sv: (v0.7.4) fixed the interpretation of specializations. the
;;;;                 specialization of a center for a dm class can take on
;;;;                 one of four values:
;;;;                     1.0: perfect specialization
;;;;                   > 1.0: graded specialization
;;;;                       t: no specialization, but read-only access
;;;;                     nil: no specialization or access
;;;;                 numeric specializations are interpreted to be the number
;;;;                 of units of the center's activation required to fuel
;;;;                 1.0 units of idealized processing and support.  also
;;;;                 reduced the size of the lp problem by only including
;;;;                 variables for each (center, dme) pair where the
;;;;                 center has a numeric specialization for the dme.
;;;;                 this eliminated a number of variables from the lp
;;;;                 problem, speeding solution time (and thus the overall
;;;;                 speed of 4caps, which is dominated by the allocation
;;;;                 problem) by an order of magnitude.  finally, ensured
;;;;                 compatibility with acl 5.0.
;;;;
;;;;   11.1999 sv: (v0.7.5) eliminated further redundancy in the lp allocation
;;;;                 problem.  simplified the lp problem by collapsing across
;;;;                 dmes of the same class.  that is, there is now one
;;;;                 variable for each (center, dm class) pair.  the
;;;;                 activation that simplex allocates to each dm class is then
;;;;                 spread evenly over the various dmes of that class.  once
;;;;                 again, this drastically reduced the number of variables
;;;;                 in the lp problem submitted to simplex, and produced
;;;;                 another order-or-magnitude speed up.
;;;;
;;;;   11.1999 sv: (v0.7.6) until now, the effects of top-level commands that
;;;;                 altered declarative memory were not immediately visible
;;;;                 because the commands were buffered until the next
;;;;                 invocation of the recognize-act loop.  this inhibited
;;;;                 interactive modeling, and thus a parameter was added to
;;;;                 allow users to override this behavior by stipulating that
;;;;                 each such command be executed immediately.[7]  combined
;;;;                 the simplex code, which had been in a separate file, into
;;;;                 the 4caps file.  finally, added a variant of the spew rhs
;;;;                 action, *spew, that permits the automatic computation of
;;;;                 the class of the dme being spewed to.
;;;;
;;;;                 [7] this parameter has since been removed.  top-level
;;;;                     commands that alter the contents of declarative
;;;;                     memory are executed immediately so that perfect
;;;;                     synchrony is maintained between the state of the
;;;;                     the system and what the user expects.  maintaining
;;;;                     this consistency is well-worth the small loss of
;;;;                     efficiency.
;;;;
;;;;   01.1999 sv: (v0.7.7) generalized the spew command to handle both the
;;;;                 case when the dm class if fixed and when it is computed
;;;;                 dynamically.  also, generalized the p@ top-level command
;;;;                 for defining productions so that it takes either a
;;;;                 center name or a list of center names.  finally,
;;;;                 bound dme activations to lie between 0 (as mandated by
;;;;                 simplex) and the new *max-act* variable, which defaults
;;;;                 to 1.0.
;;;;
;;;;   02.2000 sv: (v0.8) cleaned up the user-interface of top-level commands
;;;;                 to obey consistent naming and access conventions.  this
;;;;                 included consolidating the plethora of history commands
;;;;                 into just two, history and history@, which take numerous
;;;;                 options.
;;;;
;;;;   03.2000 sv: (v0.8.1) changed the default behavior of top-level
;;;;                 commands by eliminating the "current center" notion
;;;;                 whereby a specific center was the target of all
;;;;                 otherwise untargeted commands.  this was a reasonable
;;;;                 default given the growth of the multi-center 4caps
;;;;                 from the uni-center 3caps, where there never was any
;;;;                 ambiguity as to where commands were targeted.  adopted
;;;;                 the symmetric and equally reasonable default that
;;;;                 commands apply to every center unless otherwise
;;;;                 overridden by an "@" suffix and a targeted center or
;;;;                 list of targeted centers.  in other words, parallelism
;;;;                 reigns by default.
;;;; 
;;;;               (v0.8.2) small changes.  changed the segment recording
;;;;                 command from start-segment to end-segment; it just turns
;;;;                 out to be easier for models to use it with these
;;;;                 semantics, especially with regard to the last segment
;;;;                 of a simulation.  also renamed the "cap" measure, the
;;;;                 proportion of a center's activation utilized, to
;;;;                 the more accurate "prop".
;;;;
;;;;   04.2000 sv: (v0.8.3) added add and del macros, which should not be used
;;;;                 for new models, but may speed the process of getting old
;;;;                 models up and running.[8]  generalized set-spec@ and
;;;;                 set-specs@ to take multiple (dm class, num) pairs.  fixed
;;;;                 the spew rhs action so that the target dme can be
;;;;                 specified via the get-dme command.  changed rete network
;;;;                 to explicitly call compile on rete-node test functions
;;;;                 because acl does not do this automatically.  eliminated
;;;;                 the internal formats command in an effort to systematize
;;;;                 i/o, thus laying the groundwork for better tracing.
;;;;                 eliminated all references to the *current* center,
;;;;                 which have been internal since v0.8.1 (see the history
;;;;                 log for 03.2000).  made tracing a global condition rather
;;;;                 than center by center, controlled by the
;;;;                 global variable *tracing-p*.  removed the option of
;;;;                 running models in interpreted mode.[9]  moved the lists
;;;;                 dmes and spews and modifies performed by fired
;;;;                 instantiations from individual centers to system-wide
;;;;                 global variables *dm*, *spews*, and *modifies*.
;;;;                 eliminated the existing reset and reset@ top-level
;;;;                 commands and renamed freshen to reset.  also,
;;;;                 instantiations are recorded during firing and printed
;;;;                 later, after firing.  this was an enabling step for
;;;;                 tracing at the macrocycle level, which now prints not
;;;;                 only the activation requests of firing instantiations,
;;;;                 but also center allocations.  this corrects an
;;;;                 asynchrony between actual activation allocations and
;;;;                 those shown in the trace that has been present since
;;;;                 3caps.  *tracing-dm-p* now controls whether the
;;;;                 activation contributed by each center to each dme is
;;;;                 printed on each macrocycle.  this variable is only
;;;;                 consulted if *tracing-p* is t.  this variable is
;;;;                 accessed through the new top-level commands tracing-dm-p
;;;;                 and set-tracing-dm-p.
;;;;
;;;;                 [8] this undoes the work done on v0.5 whereby all
;;;;                     discrete actions except modify were eliminated.  (see
;;;;                     the history log entry for 11.1998.)  revolutions
;;;;                     often reach for unreasonable extremes.
;;;;                 [9] see note [3] above.
;;;;
;;;;   05.2000 sv: (v0.8.4) changed the way the 4caps allocation problem is
;;;;                 mapped to a linear programming problem in such a way
;;;;                 that secondary migrations now occur as desired.
;;;;                 (secondary migrations are when the most specialized
;;;;                 center can no longer migrate processing to the next
;;;;                 most specialized center because it too is maxed out,
;;;;                 and must thus find another destination for its processing
;;;;                 overflow.)
;;;;
;;;;   01.2001 sv: (v0.8.5) broadened the options on the HISTORY command
;;;;                 for the temporal grain size.  new options are the name
;;;;                 of the sole segment of interest and a list denoting an
;;;;                 interval of macrocycles of interest.
;;;;
;;;;   03.2001 sv: (v0.8.6) this is the version of 4CAPS used that was used
;;;;                 with pars0.9.19.lsp to generate the model data reported
;;;;                 in the original theory paper submission to psychological
;;;;                 review.
;;;;
;;;;   03.2001 sv: (v1.0) revised the nomenclature to mirror the theory paper:
;;;;                 modules have became centers and working memory has
;;;;                 become declarative memory.
;;;;
;;;;   03.2001 sv: (v1.0.1) first, stumbled upon a bug in matching.  there are
;;;;                 two entry points to the matcher, the match and rematch
;;;;                 functions.  the former is called from the recognize-act
;;;;                 loop, and matches all dmes (i.e., the contents of *dm*,
;;;;                 *spews*, and *modifies*) against all centers.  the
;;;;                 second is called following top-level commands that alter
;;;;                 dm, i.e., after top-level spew and modify commands.  it
;;;;                 only matches those centers affected by the change,
;;;;                 i.e., those specialized for the dmes involved.  this
;;;;                 leads to a subtle bug because the effect of rematching a
;;;;                 subset of specialized centers can spill over to
;;;;                 nonspecialized centers with resource limitations.
;;;;                 therefore, eliminated the rematch function; all matching
;;;;                 is done overall centers via the match function.  
;;;;                 second, eliminated calls to to the match function when
;;;;                 a top-level spew or modify command is executed.  these
;;;;                 calls were present so that the contents of dm and the
;;;;                 state of the matcher would always be consistent.  but
;;;;                 they are inefficient when a string of such top-level
;;;;                 commands are given.  now, such consistencies are ensured
;;;;                 only when they have to, i.e., when a top-level dm or
;;;;                 matches command is given or during the recognize-act
;;;;                 loop.  third, simplified the conditional statement in the
;;;;                 fire function.  it used to test whether the function was
;;;;                 being called during the running of a simulation, but such
;;;;                 a test is unnecessary because this is always the case.
;;;;
;;;;                 [10] just found a new bug -- apparently all *no tests
;;;;                 must come at the end of a production's lhs.  they can't
;;;;                 be intermingled with positive tests.  damn!
;;;;
;;;;   03.2001 sv: (v1.0.2) first, cleaned-up the functions and methods that
;;;;                 print the trace of the instantiations and dmes when a
;;;;                 model is run.  these are now more abstract, and rely on a
;;;;                 substrate of helper functions that are also shared by the
;;;;                 dm, dm@, matches, and matches@ top-level commands.  the
;;;;                 result is a better overall look that is cohesive across
;;;;                 commands and can be changed in a modular fashion.
;;;;                 second, implemented new variants of the top-level run
;;;;                 command: run-to and run-off.  these are useful for
;;;;                 simulating intervals of experimental trials where
;;;;                 where participants are not engaged in cognition, e.g.,
;;;;                 when staring a a fixation point.  third, migrated the
;;;;                 commands that computed and printed fmri measures from
;;;;                 the sentence comprehension model to the 4caps
;;;;                 architecture and generalized them accordingly.
;;;;
;;;;   08.2001 sv: (v1.1) froze the architecture at the time of completion of
;;;;                 the tower of london model (tol v1.0), which has been fit
;;;;                 to the "old" (reichle-collected) data.  this model also
;;;;                 does a sensible job on the problems of the "new" study,
;;;;                 fitting the observed behavioral data.  finally, this
;;;;                 version of the architecture also supports the first
;;;;                 working version of the tower of hanoi (toh v0.1.3) model.
;;;;                 note that both tol and toh draw on the same model of
;;;;                 executive function.
;;;;
;;;;   08.2002 sv: (v1.2) Made a number of small changes prompted by new
;;;;                 simulations of the sentence comprehension run when
;;;;                 revising the "Theory Paper" for resubmission to
;;;;                 Psychological Review.  Added a SEGMENT-END option to the
;;;;                 :TIME parameter of the HISTORY and HISTORY@ commands.
;;;;                 Also added a :VERBOSE-P parameter to these commands that
;;;;                 defaults to the value of a user-modifiable special
;;;;                 variable (whose initial value is NIL).  Revised the
;;;;                 FMRI-HISTORY command to use the same algorithms as the
;;;;                 separate RECOVERY.LSP file, especially with respect to
;;;;                 *gamma-conversion*.  Included the facility that I wrote
;;;;                 previously for Greg Sliwoski's use.  It allows the user
;;;;                 to add hook functions to the main recognize-act loop,
;;;;                 e.g., to record the number of goals activated during a
;;;;                 simulation run.  Finally, renamed "component" everywhere
;;;;                 to reflect the change in nomenclature.  Required
;;;;                 depracating commands that included "comp"; they now issue
;;;;                 a warning before passing control to their properly named
;;;;                 counterparts. 
;;;;
;;;; This implementation of a top-level command does not end with (VALUES)
;;;; because value of this function is useful -- a list of the dmes that were
;;;; spewed to.  This list can be bound by a let form on a production RHS or
;;;; in a top-level test function, and the IDs can be used to build nested dme
;;;; structures.
;;;;
;;;; Changed COMPONENTS to CENTERS.
;;;;
;;;; Implemented MACROCENTER CAPABILITY.
;;;; Added helper function FIND-DME-IF. 
;;;;
;;;; Modified HISTORY so that when looking up dme class activations in records,
;;;; does a MAPHASH based on subtypep because activations are no longer recorded
;;;; by every inherited class, but just by leaf class. 
;;;;
;;;; Eliminate recording and reporting of "raw" activations, i.e., unmultiplied
;;;; to reflect center specializations.  Only "act" activations reported.  Can
;;;; always reimplement this capability later, but dividing by specialization
;;;; when the HISTORY command is called.
;;;;
;;;; Changed *MACRO-CYCS* to *CYCLES*, *START-MCYC* to *START-CYC*, and *GAMMA-
;;;; CONVERSION* to *TIME-CONVERSION*.  These changes will will obviously break
;;;; lots of existing code, but in trivial ways.
;;;;
;;;; Re-worked the FMRI-HISTORY (and FMRI-HISTORY@) commands to better account
;;;; for the temporal mapping between 4caps cycles and real-world time (secs).
;;;;
;;;; Wrote CONNECTIVITY (and CONNECTIVITY@) commands to compute the functional
;;;; connectivity between models centers using the same correlation algorithm
;;;; used on the brain activation data.  The idea for these commands was
;;;; suggested by Vicente Malave, who also contributed the CORRELATION and
;;;; FISHER-Z functions.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; Bugs:
;;;;
;;;;   04.2002 sv: (v1.2.3) It appears that *NO tests must follow positive tests,
;;;;                 and and perhaps that *ALWAYS tests must follow these, on
;;;;                 production LHSs.  Also, does not handle (OR ...) properly,
;;;;                 at least within absence tests.  For example:
;;;;                   (*no ((~pop preferred-operator))
;;;;                     (*whole (or (equal (state (operator ~pop)) (state mc))
;;;;                                 (equal (operator ~pop) mc))))
;;;;                 and:
;;;;                   (*no ((~pop preferred-operator))
;;;;                     (or (equal (state (operator ~pop)) (state mc))
;;;;                         (equal (operator ~pop) mc)))
;;;;                 are not permitted.  Separate absence tests must be written:
;;;;                   (*no ((~pop preferred-operator))
;;;;                     (equal (state (operator ~pop)) (state mc)))
;;;;                   (*no ((~pop preferred-operator))
;;;;                     (equal (operator ~pop) mc))
;;;;
;;;;  FROM THE MR MODEL (v0.2):
;;;;  10.1.2003 sv: (v0.2) Just squashed the weirdest freaking bug.  Switched
;;;;                the general Executive Model productions so that they assert
;;;;                MR-PREFERENCEs, but mistakenly left the Mental Rotation
;;;;                Model productions asserting plain PREFERENCEs.  This
;;;;                exposed a bug in the spew RHS action.  Spew takes a
;;;;                a template and spews the specified activation to all
;;;;                dmes that fit the template.  Therefore had productions
;;;;                spewing to the same unary preferenced expressed as both
;;;;                a PREFERENCE and MR-PREFERENCE, which is to say to two
;;;;                different dmes since spew does not coalesce across
;;;;                classes, even when one class is a subclass of the other.
;;;;                *Maybe* this was the right behavior, and users should
;;;;                be warned when they instantiate both a class and its
;;;;                superclass.  Or maybe this was a bug, and users should
;;;;                not be allowed to instantiate both a class and its
;;;;                superclass.
;;;;
;;;; All dmes that do not appear on production LHS must be explicitly placed
;;;; there via an (ID ...) access to ensure their transmission to the RHS.
;;;; It is usually obvious when to do this.  An unobvious case is when the
;;;; dme is tested on the LHS, but only with *NO tests, which themselves will
;;;; not be evaluated unless at least one dme matching their class specifier
;;;; exists -- not always the case, especially at the beginning of simulations.
;;;;
;;;; Need to add an explicit HALT command to 4CAPS.
;;;;
;;;; Extend 4CAPS to allow subclasses to "alias" inherited slots.  This came up
;;;; in the dual-comprehension model, where the OPERATOR slot of the GOAL class
;;;; of the general executive model should be aliased as MODALITY.
;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; global functionality.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; the lexical environment.
;;;


;; define macro characters that delimit a ce that is not to be decomposed,
;; but evaluated whole instead.

(set-macro-character #\[ #'(lambda (stream char)
                             (declare (ignore char))
                             (let ((form (read-delimited-list #\] stream t)))
                               `(*whole ,form))))

(set-macro-character #\] (get-macro-character #\)))




;;;
;;; the common lisp and clos environment.
;;;


;; provide a layer of abstraction between those lisps that are still
;; moving from CLtL2 to ANSI and those that have already gotten there.


(defun special-symbol-p (sym)
  (and (special-operator-p sym)
       (not (macro-function sym))))


;; provide a layer of functionality between implementation-specific clos
;; functions (because the amop is not standard) and 4caps.




(defmethod class-slot-names ((class standard-class))
  (unless (clos:class-finalized-p class)
    ;(cg::ensure-class-finalized class))
      (clos::finalize-inheritance class))
    (mapcar #'clos:slot-definition-name (clos:class-slots class)))

(defmethod class-slot-initargs ((class standard-class))
  (mapcar #'(lambda (slot)
              (cons (clos:slot-definition-name slot)
                    (clos:slot-definition-initargs slot)))
          (clos:class-slots class)))


(import 'clos:class-direct-subclasses)



;;;
;;; global/special variables.
;;;


;; macro-centers.

(defparameter *macro-centers* nil)

(defparameter *macro-center-counter* 0)


;; centers.

(defparameter *centers* nil)

(defparameter *center-counter* 0)


;; compiling.


(defparameter *delete-thresh* 0.01)
(defparameter *default-dme-thresh* 0.01)
(defparameter *default-spec* 1)

(defparameter *whole-equal-p* t)

(defparameter *token-slots* (make-hash-table))


;; running.

(defparameter *cycles* 0)
(defparameter *tracing-p* nil)
(defparameter *tracing-dm-p* nil)
(defparameter *running-p* nil)

(defparameter *post-hook-fns* nil)


;; tracing information.

(defparameter *instantiation* nil)
(defparameter *instantiations* nil)

(defparameter *dmes* nil)


;; dmes.

(defparameter *dm* nil)

(defparameter *modifies* nil)
(defparameter *spews* nil)

(defparameter *max-act* 1.0)

(defparameter *dme-counter* 0)

(defparameter *dme-slots* (make-hash-table))

(defparameter *dme-recursive-p* nil)
(defparameter *front-act-p* nil)
(defparameter *summ-embeds-p* t)
(defparameter *elide-nils-p* t)


;; history.

(defparameter *act-history* nil)

(defparameter *segment-history* nil)
(defparameter *start-cyc* 1)

(defparameter *center-outer-p* t)


;; 

(defparameter *epsilon* 0.001)

(defparameter *width* 10)



;;;
;;; general 4caps utilities.
;;;


;; 

(defun almost-zerop (num)
  (< num *epsilon*))


;;

(defun shorten (name)
  (let ((str (symbol-name name)))
    (if (< (length str) *width*)
      str
      (subseq str 0 *width*))))


;;

(defun print-hash-table-values (table)
  (maphash #'(lambda (key val)
               (declare (ignore key))
               (print val))
           table)
  (values))


;;

(defun pending-dm-actions-p ()
  (or *spews* *modifies*))


;; lhs helper predicates.

(defun equals (&rest args)
  "a version of the EQUAL predicate that accepts a variable number of arguments.
   use to simplify LHS expressions."
  (let ((first-arg (first args)))
    (every #'(lambda (arg)
               (equal first-arg arg))
           (rest args))))

(defun not-equal (arg1 arg2)
   (not (equal arg1 arg2)))


;;

(defun map-macro-centers (fn)
  (mapc fn *macro-centers*))


;;

(defun map-centers (fn)
  (mapc fn *centers*))


;; (get-macro-center name)

(defun get-macro-center (name)
  (find name *macro-centers* :key #'name))


;; (get-center name)

(defun get-center (name)
  (find name *centers* :key #'name))


;; (get-dme num)

(defun get-dme (num)
  (find num *dm* :key #'id))


;; (find-dme-if predicate)

(defun find-dme-if (fn)
  (dolist (dme *dm*)
    (when (funcall fn dme)
      (return-from find-dme-if dme)))
  nil)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; hooks.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; hooks.
;;;


;;

;;; supplied function must have no required arguments.
(defun add-post-hook-fn (fn)
  (push fn *post-hook-fns*)
  (values))

(defun remove-post-hook-fn (fn)
  (setq *post-hook-fns* (delete fn *post-hook-fns*))
  (values))

(defun reset-post-hook-fns ()
  (setq *post-hook-fns* nil)
  (values))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; dmes.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; the base-dme class.
;;;


;; base definition.

(defclass base-dme ()
  ((id :accessor id)
   (act :initform 0
        :accessor act)))

(defmethod initialize-instance ((self base-dme) &rest initargs)
  (declare (ignore initargs))
  (call-next-method)
  (setf (id self) (incf *dme-counter*)))


;; printing.

(defmethod print-object ((self base-dme) stream)
  (if (and *dme-recursive-p* *summ-embeds-p*)
    (print-unreadable-object (self stream :type t)
      (princ (id self) stream))
    (let ((*dme-recursive-p* t)
          (name (class-name (class-of self))))
      (format stream "(~A" name)
      (mapc #'(lambda (slot-name)
                (let ((val (slot-value self slot-name)))
                  (unless (and (null val) *elide-nils-p*)
                    (if (eq slot-name 'act)
                      (unless *front-act-p*
                        (format stream " :~A ~,2F" slot-name val))
                      (format stream " :~A ~A" slot-name val)))))
            (gethash name *dme-slots*))
      (format stream ")"))))


;;

(defmethod below-thresh-p ((self base-dme))
  (< (act self) *delete-thresh*))


;; rhs lists.

(defmethod make-mod ((dme base-dme))
  (pushnew dme *modifies*))

(defmethod make-spew ((dme base-dme) amount)
  (let ((old-spew (assoc dme *spews*)))
    (if old-spew
      (incf (cdr old-spew) amount)
      (push (cons dme amount) *spews*))))



;;;
;;; dme utilities.
;;;


(defun dme-class-list (&optional (base-class 'base-dme))
  (mapcar #'class-name (class-direct-subclasses (find-class base-class))))

(defun dme-list (&optional dm-classes)
  (let ((dmes nil))
    (mapc #'(lambda (dme)
              (unless (and dm-classes
                           (notany #'(lambda (dm-class)
                                       (subtypep (class-name (class-of dme))
                                                 dm-class))
                                   dm-classes))
                (push dme dmes)))
          *dm*)
    (mapc #'(lambda (pair)
              (let ((dme (car pair)))
                (unless (and dm-classes
                             (notany #'(lambda (dm-class)
                                         (subtypep (class-name (class-of dme))
                                                   dm-class))
                                     dm-classes))
                  (pushnew dme dmes))))
          *spews*)
    dmes))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; tracing.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; general tracing.
;;;


;;

(defun reset-trace ()
  (when *tracing-p*
    (reset-instantiation-trace)))


;;

(defun print-traces ()
  (when (or *tracing-p* *tracing-dm-p*)
    (print-gap)
    (print-macrocycle-banner)
    (when *tracing-p*
      (print-instantiation-trace))
    (when *tracing-dm-p*
      (print-dme-trace))
    (print-heavy-separator)))


;; printing instantiations.

(defun print-macrocycle-banner ()
  (print-heavy-separator)
  (format t "~&                                MACRO CYCLE: ~A" *cycles*))

(defun print-center-separator ()
  (print-medium-separator))

(defun print-center-banner (name cycs)
  (print-center-separator)
  (format t "~&~A: ~D" name cycs))

(defun print-instantiation-separator ()
  (print-light-separator))

(defmethod print-instantiation-name (p-name)
  (format t "~&~A" p-name))

(defmethod print-instantiation-lhs (lhs)
  (mapc #'(lambda (ce-var-packet)
            (format t "~%  ~4,2F:   ~A" (first ce-var-packet) (second ce-var-packet)))
        lhs))

(defmethod print-instantiation-arrow ()
  (format t "~&-->"))


;; printing utilities.

(defun print-gap ()
  (format t "~&~%"))

(defun print-heavy-separator ()
  (format t "~&********************************************************************************"))

(defun print-medium-separator ()
  (format t "~&================================================================================"))

(defun print-light-separator ()
  (format t "~&--------------------------------------------------------------------------------"))



;;;
;;; dme tracing.
;;;


;;

(defun initialize-dme-trace ()
  (setq *dmes* (mapcar #'(lambda (dme)
                           (list dme (act dme) nil))
                       (dme-list))))


;;

(defun print-dme-trace ()
  (print-medium-separator)
  (format t "~%all centers:")
  (print-light-separator)
  (let ((*front-act-p* t))
    (mapc #'(lambda (packet)
              (let ((dme (first packet))
                    (targ-act (second packet))
                    (contrib-packets (third packet)))
                (unless (zerop (act dme))
                  (format t "~%~4,2F:~A~A" (act dme) #\tab dme)
                  (unless (= (act dme) targ-act)
                    (format t "~%~Arequested: ~4,2F" #\tab targ-act))
                  (mapc #'(lambda (contrib-packet)
                            (let* ((center (car contrib-packet))
                                   (raw-act (cdr contrib-packet))
                                   (spec (center-dme-spec center dme)))
                              (unless (zerop raw-act)
                                (format t "~%~A~A: ~4,2F (* ~4,2F = ~4,2F)"
                                        #\tab
                                        (name center)
                                        raw-act
                                        spec
                                        (* raw-act spec)))))
                        contrib-packets))))
          *dmes*)))



;;;
;;; instantiation tracing.
;;;


;; reset the instantiation trace variable for the current macrocycle.

(defun reset-instantiation-trace ()
  (setq *instantiations* nil))


;;

(defun preprocess-instantiation-trace (center p-name tok)
  (setq *instantiation* (make-instance 'instantiation
                          :cyc (cycles center)
                          :center center
                          :p-name p-name
                          :lhs (make-lhs tok))))


;;

(defun postprocess-instantiation-trace ()
  (setf (rhs *instantiation*) (nreverse (rhs *instantiation*)))
  (push *instantiation* *instantiations*)
  (setq *instantiation* nil))



;;

(defun trace-modify-action (dme slot val)
  (let ((*front-act-p* t))
    (push (list 'modify (act dme)
                        dme
                        (format nil "~A" dme)
                        slot
                        val)
          (rhs *instantiation*))))

(defun trace-spew-action (dme amount)
  (let ((*front-act-p* t))
    (push (list 'spew (act dme)
                      dme
                      (format nil "~A" dme)
                      amount)
          (rhs *instantiation*))))


;;

(defun print-instantiation-trace ()
  (map-centers #'(lambda (center)
                 (let ((first-p t))
                   (mapc #'(lambda (inst)
                             (when (eq center (center inst))
                               (when first-p
                                 (setq first-p nil)
                                 (print-center-banner (name center) (cycles center)))
                               (print-instantiation-separator)
                               (print-instantiation-name (p-name inst))
                               (print-instantiation-lhs (lhs inst))
                               (print-instantiation-arrow)
                               (print-rhs inst)))
                         *instantiations*)))))



;;;
;;; the instantiation class.
;;;


;; base class definition.

(defclass instantiation ()
  ((cyc :initarg :cyc
         :initform nil
         :accessor cyc)
   (center :initarg :center
           :initform nil
           :accessor center)
   (p-name :initarg :p-name
           :initform nil
           :accessor p-name)
   (lhs :initarg :lhs
        :initform nil
        :accessor lhs)
   (rhs :initarg :rhs
        :initform nil
        :accessor rhs)))


;; printing portions of an instantiation.

(defmethod print-rhs ((self instantiation))
  (mapc #'(lambda (action)
            (let ((action-type (first action))
                  (before-act (second action))
                  (dme (third action))
                  (dme-string (fourth action)))
              (case action-type
                (modify
                 (let ((slot (fifth action))
                       (val (sixth action)))
                   (format t "~&  MODIFY: ~4,2F:   ~A" before-act dme-string)
                   (format t "~%      By: :~A ~A" slot val)))
                (spew
                 (let ((request-amount (fifth action)))
                   (format t "~&  SPEW:   ~4,2F:   ~A"  before-act dme-string)
                   (format t "~%    With: ~,2F" request-amount)
                   (let* ((packet (assoc dme *dmes*))
                          (request-act (second packet))
                          (contrib-packets (third packet)))
                   (format t "~%    Req:  ~,2F" request-act)
                   (let ((raw-act (cdr (assoc (center self) contrib-packets)))
                         (spec (center-dme-spec (center self) dme)))
                     (format t "~%    Cont: ")
                     (if (numberp spec)
                       (format t "~,2F (* ~4,2F = ~4,2F)" raw-act spec (* raw-act spec))
                       (format t "n/a")))))))))
        (rhs self)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; centers.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; the center class.
;;;


;; base definition.

(defclass center ()
  ((name :initarg :name
         :initform nil
         :accessor name)
   (cycles :accessor cycles)
   (specials :accessor specials)
   (capacity :accessor capacity)
   (ce-nodes :accessor ce-nodes)
   (rete-nodes :accessor rete-nodes)
   (no-input-nodes :accessor no-input-nodes)
   (neg-nodes :accessor neg-nodes)
   (rhss :accessor rhss)))

(defmethod initialize-instance ((self center) &rest initargs)
  (declare (ignore initargs))
  (call-next-method)
  (unless (name self)
    (setf (name self) (intern (format nil "CENTER-~A" (incf *center-counter*)))))
  (setf (specials self) (make-hash-table))
  (setf (capacity self) nil)
  (setf (ce-nodes self) (make-hash-table))
  (setf (rete-nodes self) (make-hash-table))
  (setf (no-input-nodes self) nil)
  (setf (neg-nodes self) nil)
  (setf (rhss self) nil)
  (center-reset self nil)
  (name self))


;; printing and indenting.

(defmethod print-object ((self center) stream)
  (print-unreadable-object (self stream :type t)
    (princ (name self) stream)))


;; ce nodes.

(defmethod get-ce-node ((self center) name)
  (gethash name (ce-nodes self)))

(defmethod add-ce-node ((self center) &rest args)
  (let ((node (apply #'make-instance 'ce-node args)))
    (setf (gethash (name node) (ce-nodes self)) node)
    node))

(defmethod print-ce-nodes ((self center))
  (print-hash-table-values (ce-nodes self)))


;; rete nodes.

(defmethod get-rete-node ((self center) name)
  (gethash name (rete-nodes self)))

(defmethod get-rete-node-by-test ((self center) test)
  (maphash #'(lambda (name node)
               (declare (ignore name))
               (when (equal test (test node))
                 (return-from get-rete-node-by-test node)))
           (rete-nodes self))
  nil)

(defmethod add-rete-node ((self center) &rest args)
  (let ((node (apply #'make-instance 'rete-node :center self args)))
    (setf (gethash (name node) (rete-nodes self)) node)
    node))

(defmethod print-rete-nodes ((self center))
  (print-hash-table-values (rete-nodes self)))


;; rhss.

(defmethod map-rhss (fn (self center))
  (mapc #'(lambda (rhs)
            (apply fn rhs))
        (rhss self)))


;; resetting.

(defmethod center-reset ((self center) &optional (tokens-p t))
  (setf (cycles self) 0)
  (when tokens-p
    (maphash #'(lambda (key rete-node)
                 (declare (ignore key))
                 (setf (tokens rete-node) nil))
             (rete-nodes self)))
  (values))


;; dirty centers.

(defmethod dirty-p ((self center))
  (mapc #'(lambda (dme)
            (when (specialized-p self dme)
              (return-from dirty-p t)))
        *modifies*)
  (mapc #'(lambda (pair)
            (when (specialized-p self (car pair))
              (return-from dirty-p t)))
        *spews*)
  nil)


;; dm.
;;
;; need to share structure between CENTER-DM and IMPL-DM.

(defmethod map-dm (fn (self center))
  (mapc #'(lambda (dme)
            (when (specialized-p self dme)
              (funcall fn dme)))
        *dm*))

(defun impl-dm (class-list)
  (when (pending-dm-actions-p)
    (match))
  (let ((dmes (dme-list class-list)))
    (when dmes
      (print-medium-separator)
      (format t "~%all centers")
      (when class-list
        (format t " filtered by~{ ~A~}" class-list))
      (print-light-separator)
      (let ((*front-act-p* t))
        (mapc #'(lambda (dme)
                  (format t "~%  ~4,2F:~A~A" (act dme) #\tab dme))
              dmes))
      (print-medium-separator)))
  (values))

(defmethod center-dm ((self center) classes)
  (when (pending-dm-actions-p)
    (match))
  (unless classes
    (setq classes '(base-dme)))
  (let ((dmes nil))
    (map-dm #'(lambda (dme)
                (when (some #'(lambda (class)
                                (typep dme class))
                            classes)
                  (push dme dmes)))
            self)
    (when dmes
      (print-medium-separator)
      (format t "~%~A filtered by~{ ~A~}" (name self) classes)
      (print-light-separator)
      (let ((*front-act-p* t))
        (mapc #'(lambda (dme)
                  (format t "~%  ~4,2F:  ~A" (act dme) dme))
              dmes))))
  (values))


; the (modify ...) rhs action.

(defun center-modify (dme slot val)
  (cond ((eq slot :act)
         (error "cannot use modify to change a dme's activation. ~
                 use spew instead."))
        ((and *running-p* *tracing-p*)
         (trace-modify-action dme slot val)))
   (setf (slot-value dme (first (find slot (class-slot-initargs (class-of dme))
                                     :key #'rest :test #'member)))
        val)
   (pushnew dme *modifies*)
   dme)


; the (spew ...) rhs action.

(defun center-spew (source target weight)
  (let* ((source-act (etypecase source
                       (base-dme (act source))
                       ((eql t) 1.0)))
         (amount (* source-act weight))
         (targets (etypecase target
                    (base-dme (list target))
                    (cons (let ((targs (consistent-dmes (first target))))
                            (if targs
                              targs
                              target))))))
    (mapc #'(lambda (target2)
              (when (and *running-p* *tracing-p*)
                (trace-spew-action target2 amount))
              (make-spew target2 amount))
          targets)))

(defun consistent-dmes (dme)
  (let ((slot-names (gethash (class-name (class-of dme)) *dme-slots*))
        (dmes nil))
    (flet ((push-consistent (dme2)
             (when (and (subtypep (class-of dme2) (class-of dme))
                        (not (member dme2 dmes))
                        (every #'(lambda (slot)
                                   (if (slot-boundp dme slot)
                                     (or (member slot '(id act))
                                         (equal (slot-value dme2 slot)
                                                (slot-value dme slot)))
                                     t))
                               slot-names))
               (push dme2 dmes))))
      (mapc #'(lambda (dme)
                (push-consistent dme))
            *dm*)
      (mapc #'(lambda (pair)
                (push-consistent (car pair)))
            *spews*))
    dmes))

(defmethod map-spews (fn (self center))
  (mapc #'(lambda (pair)
            (when (specialized-p self (car pair))
              (funcall fn (car pair) (cdr pair))))
        *spews*))


;; specialization of the center for various dme classes.

(defmethod center-specs ((self center) dme-classes)
  (unless dme-classes
    (setq dme-classes (dme-class-list)))
  (format t "~&~A:" (name self))
  (mapc #'(lambda (dme-class)
            (let ((spec (center-dme-class-spec self dme-class)))
              (when spec
                (format t "~%  ~A:~A" dme-class #\tab)
                (if (numberp spec)
                  (format t "~,2F" spec)
                  (format t "~A" spec)))))
        dme-classes))

(defmethod center-set-spec ((self center) dme-class num)
  (setf (gethash dme-class (specials self)) num))

(defmethod center-dme-class-spec ((self center) (dme-class symbol))
  (center-dme-spec self (make-instance dme-class)))

(defmethod center-dme-spec ((self center) (dme base-dme))
  (multiple-value-bind (spec in-p)
                       (gethash 'base-dme (specials self))
    (if in-p
      spec
      *default-spec*)))

(defmethod specialized-p ((self center) (dme base-dme))
  (center-dme-spec self dme))


;; helper functions.

(defmethod instantiations-p ((self center))
  (some #'(lambda (rhs)
            (tokens (get-rete-node self (second rhs))))
        (rhss self)))

(defmethod map-records (fn (self center) (dme base-dme))
  "helper function that maps the records of ce-nodes. a record contains, ~
   for a given ce-node, a hash table dmes of the desired class, where ~
   each record contains the subset of these dmes above the record's ~
   threshold."
  (maphash #'(lambda (name ce-node)
               (when (typep dme (find-class name))
                 (maphash #'(lambda (thresh record)
                              (funcall fn thresh record))
                          (records ce-node))))
           (ce-nodes self)))



;;;
;;; the compiler.
;;;


;; top-level interface.

(defmethod p-compile ((self center) name ce-vars body)
  (setq name (non-colliding-name self name))
  (zero-counters self)
  (setq body (nsubst-ce-vars self ce-vars (nsubst-binds body) t))
  (multiple-value-bind (lhs rhs) (npartition body)
    (setq lhs (macroexpand-lhs (case (length lhs)
                                 (0 (list 'and))
                                 (1 (cons 'and lhs))
                                 (t (reduce #'(lambda (ce1 ce2)
                                                (list 'and ce1 ce2))
                                            lhs)))))
    (let ((node-name (name (decompose self lhs))))
      (push (list name node-name (make-rhs-fn node-name rhs)) (rhss self))))
  (format t "~&Compiled ~A: ~A" (name self) name))


;; helper functions.

(defmethod non-colliding-name ((self center) name)
  (if (assoc name (rhss self))
    (do ((name2 (intern (format nil "~A*" (symbol-name name)))
                (intern (format nil "~A*" (symbol-name name2)))))
        ((null (assoc name2 (rhss self))) name2))
    name))

(defun nsubst-binds (body)
  (mapc #'(lambda (expr)
            (when (consp expr)
              (case (op-of expr)
                (bind
                 (nsubst-arg (third expr) (second expr) body))
                ((no *no)
                 (setf (cddr expr) (nsubst-binds (cddr expr)))))))
        body)
  (delete-if #'(lambda (expr)
                 (and (consp expr) (eq (op-of expr) 'bind)))
             body))

(defmethod nsubst-ce-vars ((self center) ce-var-lists body &optional ensure-p)
  (let ((new-ce-vars nil))
    (mapc #'(lambda (ce-var-list)
              (let ((ce-var (first ce-var-list))
                    (ce-name (second ce-var-list))
                    (ce-thresh (if (third ce-var-list)
                                 (third ce-var-list)
                                 *default-dme-thresh*)))
                (when (and ensure-p (not (in-lhs-p ce-var body)))
                  (push ce-var body))
                (let ((new-ce-var (retrieve-alias self ce-name ce-thresh)))
                  (push new-ce-var new-ce-vars)
                  (nsubst-arg new-ce-var ce-var body))))
          ce-var-lists)
    (values body new-ce-vars)))

(defun nsubst-arg (new old expr)
  (do* ((expr2 expr (rest expr2))
        (arg (first expr2) (first expr2)))
       ((null expr2))
    (cond ((and (atom arg) (eq arg old))
           (setf (first expr2) new))
          ((not-quote-p arg)
           (nsubst-arg new old arg)))))

(defun in-lhs-p (arg expr)
  (cond ((null expr)
         nil)
        ((atom expr)
         (eq arg expr))
        ((quote-p expr)
         nil)
        (t
         (mapc #'(lambda (expr2)
                   (cond ((eq expr2 '-->)
                          (return-from in-lhs-p nil))
                         ((in-lhs-p arg expr2)
                          (return-from in-lhs-p t))))
               expr)
         nil)))

(defun npartition (body)
  (if (eq (first body) '-->)
    (values nil (rest body))
    (let* ((n (position '--> body))
           (rhs (nthcdr (1+ n) body)))
      (rplacd (nthcdr (1- n) body) nil)
      (values body rhs))))

(defmacro *always (form)
  `(*no ((,(gensym) base-dme))
        (not ,form)))

(defun macroexpand-lhs (expr)
  (cond ((atom expr)
         expr)
        ((quote-p expr)
         expr)
        ((member (op-of expr) '(no *no))
         (list* '*no
                (first (args-of expr))
                (mapcar #'macroexpand-lhs (rest (args-of expr)))))
        ((and (macro-function (op-of expr))
              (not (eq (op-of expr) 'and)))
         (macroexpand-lhs (macroexpand expr)))
        (t
         (cons (op-of expr) (mapcar #'macroexpand-lhs (args-of expr))))))

(defmethod decompose ((self center) expr)
  (cond ((or (member (op-of expr) '(not null not-equal))
             (eq (op-of expr) '*no)
             (special-symbol-p (op-of expr)))
         (make-node self expr))
        ((and *whole-equal-p* (eq (op-of expr) 'equal))
         (make-node self expr))
        ((member (op-of expr) '(*whole))
         (make-node self (first (args-of expr))))
        ((eq (op-of expr) '*static)
         (make-node self (list 'identity (eval (first (args-of expr))))))
        ((eq (op-of expr) '*dynamic)
         (make-node self (list 'identity (first (args-of expr)))))
        ((and (eq (op-of expr) 'and)
              (second (args-of expr))
              (eq (op-of (second (args-of expr))) '*no))
         (let ((pos-expr (first (args-of expr)))
               (neg-expr (second (args-of expr))))
           (multiple-value-bind (neg-expr2 ce-vars)
                                (nsubst-ce-vars self
                                               (first (args-of neg-expr))
                                               (rest (args-of neg-expr)))
             (make-node self (list 'nand
                                   (if (not-quote-p pos-expr)
                                     (name (decompose self pos-expr))
                                     pos-expr)
                                   ce-vars
                                   (cons 'and neg-expr2))))))
        (t
         (make-node self (cons (op-of expr)
                               (mapcar #'(lambda (arg)
                                           (if (not-quote-p arg)
                                             (name (decompose self arg))
                                             arg))
                                       (args-of expr)))))))

(defmethod make-node ((self center) expr)
  (let ((old-node (get-rete-node-by-test self expr)))
    (if old-node
      old-node
      (add-rete-node self :name (gentemp "VAR-") :test expr))))

(defun make-rhs-fn (node-name rhs)
  (eval
   `(function
     (lambda (tok)
       ,@(mapcan #'(lambda (slot-name)
                     (when (ce-var-name-p slot-name)
                       `((set ',slot-name (slot-value tok ',slot-name)))))
                 (gethash node-name *token-slots*))
       ,.rhs))))


;; alias assignment (for renaming ce-vars).

(defmethod retrieve-alias ((self center) ce-name ce-thresh)
  (let ((ce-node (get-ce-node self ce-name)))
    (unless ce-node
      (setq ce-node (add-ce-node self :name ce-name)))
    (let ((record (gethash ce-thresh (records ce-node))))
      (unless record
        (setq record (cons 0 nil))
        (setf (gethash ce-thresh (records ce-node)) record))
      (when (= (car record) (length (cdr record)))
        (let ((new-alias (gentemp "CE-VAR-")))
          (setf (cdr record) (nconc (cdr record) (list new-alias)))
          (add-rete-node self :name new-alias :test ce-thresh)))
      (prog1
        (nth (car record) (cdr record))
        (incf (car record))))))

(defmethod zero-counters ((self center))
  (maphash #'(lambda (name ce-node)
               (declare (ignore name))
               (maphash #'(lambda (thresh record)
                            (declare (ignore thresh))
                            (setf (car record) 0))
                        (records ce-node)))
           (ce-nodes self)))


;; helper accessors and predicates.

(defun op-of (expr)
  (first expr))

(defun args-of (expr)
  (rest expr))

(defun quote-p (expr)
  (and (consp expr) (eq (op-of expr) 'quote)))

(defun not-quote-p (expr)
  (and (consp expr) (not (eq (op-of expr) 'quote))))



;;;
;;; the matcher.
;;;


;; the main loop.

(defun impl-run (cycs)
  (when (pending-dm-actions-p)
    (match))
  (let ((*running-p* t))
    (do ()
        ((or (zerop cycs) (notany #'instantiations-p *centers*)))
      (incf *cycles*)
      (decf cycs)
      (reset-trace)
      (map-centers #'fire)
      (match t)
      (print-traces)
      (mapc #'funcall *post-hook-fns*)))
  (values))


(defun impl-run-to (cycs)
  (cond ((< cycs *cycles*)
         (format t "~&Already past macrocycle ~A.  (The curent macrocycle is ~A.)" cycs *cycles*))
        ((= cycs *cycles*)
         (format t "~&Already at macrocycle ~A." cycs))
        (t
         (impl-run-off (- cycs *cycles*))))
  (values))

(defun impl-run-off (cycs)
  (let ((target-cycs (+ *cycles* cycs)))
    (impl-run cycs)
    (when (< *cycles* target-cycs)
      (when *act-history*
        (incf *cycles*)
        (match t)
        (when (< *cycles* target-cycs)
          (dolist (center-record *act-history*)
            (let ((last-cyc-table (cdr (second center-record))))
              (do ((cyc (1+ *cycles*) (1+ cyc)))
                  ((> cyc target-cycs))
                (push (cons cyc last-cyc-table) (rest center-record)))))))
      (setq *cycles* target-cycs)))
  (values))


;; fire instantiations.

(defmethod fire ((self center))
  (when (instantiations-p self)
    (incf (cycles self))
    (map-rhss #'(lambda (p-name node-name fn)
                  (mapc #'(lambda (tok)
                            (when *tracing-p*
                              (preprocess-instantiation-trace self p-name tok))
                            (funcall fn tok)
                            (when *tracing-p*
                              (postprocess-instantiation-trace)))
                        (tokens (get-rete-node self node-name))))
              self)))


;; the main match process.

;;;^^^ New with v1.2.2.
(defmacro do-pos-list ((pos item list &optional result) &body forms)
  (let ((rest-list (gensym)))
    `(do ((,pos 0 (1+ ,pos))
          (,rest-list ,list (rest ,rest-list)))
         ((null ,rest-list) ,result)
       (let ((,item (first ,rest-list)))
         ,@forms))))


;;;^^^ Need to write a smart map-dmes function that applies a function to each dme once,
;;;^^^ even those that appear on both *DM* and *SPEWS*.
;;;
;;;^^^ Some confusion between RECORDING and RUNNING booleans.
(defun match (&optional record-p)

  ;;^^ Perhaps move these to an "outer function".
  (map-centers #'clear-negs)
  (map-centers #'clear-nos)
  (map-centers #'match-nos)
  
  (request-activation)

  (let ((num-cents (length *centers*))
        (num-mcents (length *macro-centers*))
        (dmes (dme-list))
        (cogfns nil))
    (dolist (dme dmes)
      (cond ((minusp (act dme))
             (setf (act dme) 0.0))
            ((> (act dme) *max-act*)
             (setf (act dme) *max-act*)))
      
      ;; The COGFNS list has an entry for each class represented by a dme
      ;; in declarative memory.  Each entry has four items:
      ;;   - the cognitive function (class) name
      ;;   - an exemplar dme of the class (need for retrieving center
      ;;     specializations for classes via CENTER-DME-SPEC)
      ;;   - the requested activation of all dmes of the class
      ;;   - a slot to record the allocated activation for dmes of the class
      ;;   - a slot to record the proportion of request activation actually
      ;;     allocated.
      ;;   - pairs recording the action contributions of each center.
      (let* ((cogfn-name (class-name (class-of dme)))
             (cogfn (assoc cogfn-name cogfns)))
        (if cogfn
          (incf (third cogfn) (act dme))
          (push (list cogfn-name dme (act dme) 0.0 1.0) cogfns))))
    
    ;;^^ Does the DME-TRACE really have to be housed in separate functions and
    ;;^^ and the global variable *DMES*?  If so, can this be made more modular?
    (when *running-p*
      (initialize-dme-trace))
    
    (let* ((num-cogfns (length cogfns))
           
           ;; The COGFNS-CENTS list has an entry for each (center, cogfn)
           ;; where each center has some (numeric) specialization for the
           ;; cognitive function cogfn.  Each entry has four items:
           ;;   - a list of cognitive function (class) names.
           ;;   - the center
           ;;   - the specialization of the center for those classes.
           ;;   - the allocated activation by the center for dmes of those
           ;;     classes.
           (cogfns-cents (let ((temp ()))
                           (dolist (cent *centers*)
                             (let ((cogfns-cent ()))
                               (dolist (cogfn cogfns)
                                 (let ((spec (center-dme-spec cent (second cogfn))))
                                   (when (numberp spec)
                                     (setf cogfn (nconc cogfn (list (cons cent 0.0))))
;                                     (push (cons cent 0.0) (nthcdr 5 cogfn))
                                     (let ((cogfn-cent (find spec cogfns-cent :key #'third)))
                                       (if cogfn-cent
                                         (push (first cogfn) (first cogfn-cent))
                                         (push (list (list (first cogfn)) cent spec 0.0)
                                               cogfns-cent))))))
                               (setq temp (nconc temp (nreverse cogfns-cent)))))
                           temp))
           (num-cogfns-cents (length cogfns-cents))
           
           ;;^^ modified
           (num-lp-cons (+ num-cents num-mcents num-cogfns))
           
           (num-lp-vars (+ num-cogfns-cents num-lp-cons))
           
           (problem-lhs (make-array (list num-lp-cons num-lp-vars)
                                    :initial-element 0))
           (problem-rhs (make-array num-lp-cons
                                    :initial-contents (nconc (mapcar #'(lambda (cent)
                                                                         (or (capacity cent)
                                                                             most-positive-fixnum))
                                                                     *centers*)
                                                             
                                                             ;;^^
                                                             (mapcar #'(lambda (mcent)
                                                                         (or (capacity mcent)
                                                                             most-positive-fixnum))
                                                                     *macro-centers*)
                                                             
                                                             (mapcar #'third cogfns))))
           (objective (make-array num-lp-vars :initial-element 0)))

      (do-pos-list (col cogfn-cent cogfns-cents)
        (let ((cent-pos (position (second cogfn-cent) *centers*))
              (spec (third cogfn-cent)))
          
          (setf (aref problem-lhs cent-pos col) spec)
          
          (do-pos-list (mcent-pos mcent *macro-centers*)
            (when (micro-center-p (second cogfn-cent) mcent)
              (setf (aref problem-lhs (+ num-cents mcent-pos) col) spec)))

          (let* ((requests (mapcar #'(lambda (cogfn-name)
                                       (third (find cogfn-name cogfns :key #'first)))
                                   (first cogfn-cent)))
                 (total (apply #'+ requests)))

            (unless (zerop total)
              (mapc #'(lambda (cogfn-name request)
                        (let ((cogfn-pos (position cogfn-name cogfns :key #'first)))
                          (setf (aref problem-lhs (+ num-cents num-mcents cogfn-pos) col)
                                (/ request total))))
                    (first cogfn-cent) requests)))
          
          (setf (aref objective col) (float (- (/ 1 spec))))))
      
      (dotimes (cons-pos num-lp-cons)
        (setf (aref problem-lhs cons-pos (+ num-cogfns-cents cons-pos)) 1))
      
      (dotimes (cogfn-pos num-cogfns)
        (setf (aref objective (+ num-cogfns-cents num-cents num-mcents cogfn-pos)) 1))
      
      (let ((solution (multiple-value-list (simplex problem-lhs problem-rhs objective))))
        (if (first solution)
          (let ((act-vector (first (second solution)))
                (records (when record-p
                           (mapcar #'(lambda (cent)
                                       (list cent (make-hash-table) 0))
                                   *centers*))))
            
            (do-pos-list (col cogfn-cent cogfns-cents)
              (let ((cent (second cogfn-cent))
                    (spec (third cogfn-cent))
                    (raw-act (float (elt act-vector col))))
                (unless (almost-zerop raw-act)
                  (setf (fourth cogfn-cent) raw-act)
                  (let* ((requests (mapcar #'(lambda (cogfn-name)
                                               (third (find cogfn-name cogfns :key #'first)))
                                           (first cogfn-cent)))
                         (total (apply #'+ requests)))
                    (unless (zerop total)
                      (mapc #'(lambda (cogfn-name request)
                                (let ((prop-act (* raw-act (/ request total))))
                                  (incf (fourth (assoc cogfn-name cogfns)) prop-act)
                                  (when *running-p*
                                    (let* ((cogfn (assoc cogfn-name cogfns))
                                           (packets (nthcdr 5 cogfn))
                                           (packet (assoc cent packets)))
                                      (incf (cdr packet) prop-act)))
                                  (when record-p
                                    (let* ((record (assoc cent records))
                                           (table (second record))
                                           (spec-act (* spec prop-act)))
                                      (incf (third record) spec-act)
                                      (incf (gethash cogfn-name table 0.0) spec-act)))))
                            (first cogfn-cent) requests))))))

            (dolist (cogfn cogfns)
              (unless (zerop (third cogfn))
                (setf (fifth cogfn) (/ (fourth cogfn) (third cogfn)))))
            (dolist (dme dmes)
              (setf (act dme)
                    (* (act dme) (fifth (assoc (class-name (class-of dme)) cogfns)))))

            ;;^^ change test to (and *running-p* (or *trace-p* *trace-dm-p*)) ???
            ;;^^  This rather opaque code records information for the production
            ;;    trace to be able to document from which center each dme gets
            ;;    its activation.
            (when *running-p*
              (dolist (dme-packet *dmes*)
                (let* ((dme (first dme-packet))
                       (dme-cl (class-name (class-of dme)))
                       (cogfn (assoc dme-cl cogfns))
                       (alloc-act (fourth cogfn)))
                  (dolist (packet (nthcdr 5 cogfn))
                    (push (cons (car packet) (* (act dme) (if (zerop alloc-act)
                                                            0.0
                                                            (/ (cdr packet) alloc-act))))
                          (third dme-packet))))))
            (when record-p
              (dolist (record records)
                (let ((cent (first record))
                      (table (second record)))
                  (setf (gethash 'total table) (third record))
                  (push (cons *cycles* table)
                        (rest (assoc cent *act-history*)))))
              
              ;;^^
              ;; RECORD MACRO-CENTER TRACE INFORMATION HERE.
              
              ))
          
          (error "SIMPLEX UNABLE TO COMPUTE AN ALLOCATION SOLUTION ON MACROCYCLE ~A." *cycles*)))))

  (allocate-activation)
  (map-centers #'match-negs)
  (setq *modifies* nil)
  (setq *spews* nil))


;; update the rete network.

(defmethod clear-negs ((self center))
  (mapc #'(lambda (node)
            (remove-tokens self node))
        (neg-nodes self)))

(defmethod clear-nos ((self center))
  (mapc #'(lambda (node)
            (recursive-remove-tokens self node))
        (no-input-nodes self)))

(defmethod match-nos ((self center))
  (mapc #'(lambda (node)
            (match-no-input-node self node))
        (no-input-nodes self)))

(defun request-activation ()
  (mapc #'(lambda (pair)
            (incf (act (car pair)) (cdr pair)))
        *spews*))

(defun allocate-activation ()
  (mapc #'(lambda (pair)
            (let ((dme (car pair)))
              (unless (or (member dme *dm*) (below-thresh-p dme))
                (map-centers #'(lambda (center)
                              (when (specialized-p center dme)
                                (add-rete-dme center dme)))))))
        *spews*)
  (mapc #'(lambda (dme)
            (cond ((below-thresh-p dme)
                   (map-centers #'(lambda (center)
                                 (when (specialized-p center dme)
                                   (del-rete-dme center dme)))))
                  ((member dme *modifies*)
                   (map-centers #'(lambda (center)
                                 (when (specialized-p center dme)
                                   (del-rete-dme center dme)
                                   (add-rete-dme center dme)))))
                  (t
                   (map-centers #'(lambda (center)
                                 (when (specialized-p center dme)
                                   (center-rete-dme center dme)))))))
        *dm*)
  (setq *dm* (delete-if #'below-thresh-p
                        (nunion (mapcar #'car *spews*) *dm*))))


(defmethod match-negs ((self center))
  (mapc #'(lambda (node)
            (match-neg-node self node))
        (neg-nodes self)))


;; propogate dme changes through the rete network.

(defmethod del-rete-dme ((self center) (dme base-dme))
  (map-records #'(lambda (thresh record)
                   (declare (ignore thresh))
                   (mapc #'(lambda (ce-var)
                             (remove-dme-tokens self dme ce-var ce-var))
                         (cdr record)))
               self dme))

(defmethod add-rete-dme ((self center) (dme base-dme))
  (map-records
   #'(lambda (thresh record)
       (when (> (act dme) thresh)
         (mapc #'(lambda (ce-var)
                   (let ((ce-var-node (get-rete-node self ce-var))
                         (new-tok (make-instance ce-var 'value dme ce-var dme)))
                     (push new-tok (tokens ce-var-node))
                     (mapc #'(lambda (var)
                               (match-token self new-tok var ce-var))
                           (outs ce-var-node))))
               (cdr record))))
   self dme))

(defmethod center-rete-dme ((self center) (dme base-dme))
  (map-records
   #'(lambda (thresh record)
       (mapc #'(lambda (ce-var)
                 (let* ((ce-var-node (get-rete-node self ce-var))
                        (in-p (find-if #'(lambda (tok)
                                           (eq (slot-value tok ce-var) dme))
                                       (tokens ce-var-node))))
                   (when (or (and in-p (< (act dme) thresh))
                             (and (not in-p) (> (act dme) thresh)))
                     (del-rete-dme self dme)
                     (add-rete-dme self dme)
                     (return-from center-rete-dme))))
             (cdr record)))
   self dme))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; the network.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; the token class.
;;;


(defclass token ()
  ((value :initarg value
          :initform nil
          :accessor value)))

(defmethod print-object ((self token) stream)
  (format stream "(~A" (value self))
  (dolist (slot-name (gethash (class-name (class-of self)) *token-slots*))
    (when (and (not (eq slot-name 'value)) (slot-boundp self slot-name))
      (format stream " ~A:~A" slot-name (slot-value self slot-name))))
  (format stream ")"))

(defmethod make-lhs ((self token))
  (let ((lhs nil)
        (*front-act-p* t))
    (dolist (slot-name (gethash (class-name (class-of self)) *token-slots*))
      (when (ce-var-name-p slot-name)
        (let ((dme (slot-value self slot-name)))
          (push (list (act dme) (format nil "~A" dme)) lhs))))
    (nreverse lhs)))




;;;
;;; network node classes.
;;;


;; the basic network node class from which others inherit.

(defclass b-node ()
  ((name :initarg :name
         :accessor name)))

(defmethod print-object ((self b-node) stream)
  (format stream "~A" (name self))
  (dolist (slot-name (class-slot-names (class-of self)))
    (when (and (not (eq slot-name 'name)) (slot-boundp self slot-name))
      (format stream "~&  ~A: ~A" slot-name (slot-value self slot-name)))))


;; the ce-node class.

(defclass ce-node (b-node)
  ((records :initarg :records
            :initform (make-hash-table)
            :accessor records)))


;; the rete node class.

(defclass rete-node (b-node)
  ((test :initarg :test
         :initform nil
         :accessor test)
   (tokens :initform nil
       :accessor tokens)
   (test-fn :accessor test-fn)
   (out-vars :accessor out-vars)
   (pos-vars :initform nil
             :accessor pos-vars)
   (neg-vars :initform nil
             :accessor neg-vars)
   (outs :initarg :outs
         :initform nil
         :accessor outs)))

(defmethod initialize-instance ((self rete-node) &rest initargs
                                                 &key center)
  (apply #'call-next-method (remf initargs 'center))
  (proclaim `(special ,(name self)))
  (compute-vars self center)
  (make-new-token-class self)
  (cond ((numberp (test self))
         )
        ((and (null (pos-vars self) ) (null (neg-vars self)))
         (push self (no-input-nodes center)))
        ((null (neg-vars self))
         (dolist (pos-var (pos-vars self))
           (push (name self) (outs (get-rete-node center (first pos-var)))))
         (setf (test-fn self) (make-token-test-fn self)))
        (t

         ;; critical NCONC, not PUSH, for getting consecutive NO tests to
         ;; evaluate properly!
         (setf (neg-nodes center) (nconc (neg-nodes center) (list self)))

         (setf (test-fn self) (make-neg-node-test-fn self)))))

(defmethod print-object ((self rete-node) stream)
  (format stream "~A" (name self))
  (dolist (slot-name (gethash (name self) *token-slots*))
    (when (and (not (eq slot-name 'name)) (slot-boundp self slot-name))
      (format stream "~&  ~A: ~A" slot-name (slot-value self slot-name)))))

(defmethod compute-vars ((node rete-node) (the-center center))
  (let ((the-test (test node)))
    (cond ((numberp the-test)
           (setf (pos-vars node) (list (list (name node) (name node)))))
          ((eq (op-of the-test) 'nand)
           (setf (pos-vars node)
                 (list (out-vars (get-rete-node the-center
                                                (first (args-of the-test))))))
           (setf (neg-vars node) (second (args-of the-test))))
          (t
           (let ((p-vars nil))
             (labels
               ((helper (expr)
                  (dolist (arg (args-of expr))
                    (cond ((not-quote-p arg)
                           (helper arg))
                          ((atom arg)
                           (let ((arg-node (get-rete-node the-center arg)))
                             (when (and arg-node (not (assoc arg p-vars)))
                               (push (out-vars arg-node) p-vars))))))))
               (helper the-test))
             (setf (pos-vars node) (nreverse p-vars))))))
  (let ((o-vars nil))
    (dolist (pos-var (pos-vars node))
      (dolist (ce-arg (rest pos-var))
        (pushnew ce-arg o-vars)))
    (setf (out-vars node) (cons (name node) (nreverse o-vars)))))

(defmethod make-new-token-class ((self rete-node))
  (let ((unique-args nil))
    (dolist (pos-var (pos-vars self))
      (dolist (arg pos-var)
        (pushnew arg unique-args)))
    (eval `(defclass ,(name self) (token)
             (,@(mapcar #'(lambda (slot)
                            `(,slot :initarg ,slot))
                        (nreverse unique-args))))))
  (setf (gethash (name self) *token-slots*)
        (class-slot-names (find-class (name self)))))

(defun ce-var-name-p (name)
  (and (char= (schar (symbol-name name) 0) #\C)
       (char= (schar (symbol-name name) 1) #\E)
       (char= (schar (symbol-name name) 2) #\-)))



;;;
;;; running the network.
;;;


;; dispatch functions.

(defmethod match-no-input-node ((self center) (the-node rete-node))
  (let ((new-tok (make-instance (name the-node)
                   'value (eval (test the-node)))))
    (setf (tokens the-node) (list new-tok))
    (dolist (var (outs the-node))
      (match-token self new-tok var (name the-node)))))

(defmethod remove-tokens ((self center) (node rete-node))
  (setf (tokens node) nil))

(defmethod recursive-remove-tokens ((self center) (node rete-node))
  (when (tokens node)
    (remove-tokens self node)
    (dolist (var (outs node))
      (recursive-remove-tokens self (get-rete-node self var)))))

(defmethod remove-dme-tokens ((self center) (dme base-dme) var ce-var)
  (let ((node (get-rete-node self var)))
    (setf (tokens node) (delete-if #'(lambda (tok)
                                       (eq (slot-value tok ce-var) dme))
                                   (tokens node)))
    (mapc #'(lambda (var2)
              (remove-dme-tokens self dme var2 ce-var))
          (outs node))))

(defmethod match-token ((self center) (tok token) var arg)
  (let ((node (get-rete-node self var)))
    (funcall (test-fn node) self node arg tok)))

(defmethod match-neg-node ((self center) (node rete-node))
  (funcall (test-fn node) self node))


;; the compiler.

;;; make a matching function for a positive rete node.
(defmethod make-token-test-fn ((self rete-node))
  (eval `(compile nil '(lambda (center node arg-alias tok)
                         (set arg-alias (value tok))
                         ,(if (= (length (pos-vars self)) 1)
                            (make-core-test-fn self)
                            (make-input-test-fn self))))))

(defmethod make-input-test-fn ((self rete-node))
  (let* ((pos-vars (pos-vars self))
         (tl-pos-vars (mapcar #'(lambda (pos-var)
                                  (cons (first pos-var) (gentemp "TOK-")))
                              pos-vars)))
    `(let (,@(mapcar #'(lambda (tl-pos-var)
                         `(,(rest tl-pos-var)
                           (tokens (get-rete-node center ',(first tl-pos-var)))))
                     tl-pos-vars))
       (cond ,@(mapcar #'(lambda (pos-var tl-pos-var)
                           `((eq arg-alias ',(first pos-var))
                             ,(let ((other-args (remove tl-pos-var
                                                        tl-pos-vars)))
                                `(when (and ,@(mapcar #'rest other-args))
                                   ,(expand-test-fn self
                                                    (list pos-var)
                                                    (remove pos-var pos-vars)
                                                    other-args)))))
                       pos-vars tl-pos-vars)))))

(defmethod expand-test-fn ((self rete-node) old-vars new-vars new-tl-vars)
  (if new-vars
    (let* ((new-var (first new-vars))
           (var (first new-var))
           (new-tl-var (first new-tl-vars))
           (iter-sym (gentemp (symbol-name var))))
      (multiple-value-bind (old-args new-args)
                           (partition-args new-var old-vars)
        (let ((old-tests (mapcar #'(lambda (old-arg)
                                     `(eq ,old-arg
                                          (slot-value ,iter-sym ',old-arg)))
                                 old-args)))
          `(dolist (,iter-sym ,(rest new-tl-var))
             (when (and ,@old-tests)
               (set ',var (value ,iter-sym))
               ,@(mapcar #'(lambda (new-arg)
                             `(set ',new-arg (slot-value ,iter-sym ',new-arg)))
                         new-args)
               ,(expand-test-fn self
                                (cons new-var old-vars)
                                (rest new-vars)
                                (rest new-tl-vars)))))))
    (make-core-test-fn self)))

(defmethod make-core-test-fn ((self rete-node))
  (let ((name (name self)))
    `(let ((value ,(test self)))
       (when value
         (let ((new-tok (make-instance ',name
                          ,@(mapcan #'(lambda (slot-name)
                                        `(',slot-name ,slot-name))
                                    (gethash name *token-slots*)))))
           (push new-tok (tokens node))
           (dolist (next-alias (outs node))
             (match-token center new-tok next-alias ',name)))))))

(defun partition-args (new-var old-vars)
  (let ((old nil)
        (new nil))
    (dolist (var (rest new-var))
      (if (find var old-vars :key #'rest :test #'member)
        (push var old)
        (push var new)))
    (values old new)))

;;; make a matching function for a negative rete node.
(defmethod make-neg-node-test-fn ((self rete-node))
  (let ((pos-var (first (first (pos-vars self)))))
    (eval
     `(function
       (lambda (center node)
         (dolist (pos-tok (tokens (get-rete-node center ',pos-var)))
           (block next-pos-token
             (set ',pos-var (value pos-tok))
             ,@(mapcar #'(lambda (slot-name)
                           `(set ',slot-name
                                 (slot-value pos-tok ',slot-name)))
                       (gethash pos-var *token-slots*))
             ,(labels
                ((check (neg-ce-vars)
                   (cond (neg-ce-vars
                          (let ((neg-tok (gensym)))
                            `(dolist (,neg-tok (tokens (get-rete-node
                                                        center
                                                        ',(first neg-ce-vars))))
                               (set ',(first neg-ce-vars) (value ,neg-tok))
                               ,(check (rest neg-ce-vars)))))
                         (t
                          `(when (eval ',(third (args-of (test self))))
                             (return-from next-pos-token))))))
                (check (neg-vars self)))
             (let ((new-tok (make-instance ',(name self))))
               ,@(mapcar #'(lambda (slot-name)
                             `(setf (slot-value new-tok ',slot-name)
                                    (symbol-value ',slot-name)))
                         (gethash (name self) *token-slots*))
               (push new-tok (tokens node)))))
         (dolist (new-tok (tokens node))
           (dolist (var (outs node))
             (match-token center new-tok var ',(name self)))))))))



;;;
;;; the simplex algorithm.
;;;


;; header comment.

;; Simplex Algorithm and its demonstration
;; Bruno Haible 25.09.1986, 30.5.1991, 22.4.1992
;; Common Lisp version
;; English version

;; Copyright (c) Bruno Haible 1991, 1992.
;; This file may be copied under the terms of the GNU General Public License.


;; types definitions.

(deftype Zahl () 'rational) ; abbreviation: R

; Should this be changed to non-exact numbers (floats), uncomment the
; portion #| ... |# of code and eliminate the calls to the function rational.
(deftype Zahl-Vektor () '(simple-array Zahl 1)) ; abbreviation: R^n
(deftype Zahl-Matrix () '(simple-array Zahl 2)) ; abbreviation: R^mxn


;; the algorithm itself.

; Notation:
; indices   1-based in mathematical theory, 0-based in this implementation
; A`        the transpose of A
; x[i]      (aref x i)
; A[i,j]    (aref A i j)
; <u,v>     u`*v = sum(i>=1, u[i]*v[i])

; Input: A, an mxn matrix of numbers,
;        b, an m vector of numbers,
;        c, an n vector of numbers.
; Solves a canonical optimisation problem:
; ( C ) Among the y in R^n with A*y=b, y>=0 find those with <c,y> = Min
; ( C* ) Among the z in R^m with x=A`*z+c>=0 find those with <b,z> = Min
; See: Koulikov, Alg`ebre et th'eorie des nombres, Chap. 6.1.
; Output: 1st value: flag if solvable, NIL or T,
;         if solvable:
;           2nd value: solution of ( C ), the linear problem LP:
;                      list containing
;                      - the solution y
;                      - the optimal value of <c,y>
;           3rd value: solution of ( C* ), the dual problem DP:
;                      list containing
;                      - the solution x
;                      - the constant terms Z for the z's
;                      - the dependencies ZZ between the z's
;                      - the optimal value of <b,z>
;                      The general solution has the following form:
;                      If ZZ[i,i]=T, the variable z_i is unrestricted.
;                      Otherwise ZZ[i,i]=NIL, and the variable z_i is calculated by
;                      z_i = Z[i] + sum(j=1,...,m with Z[j,j]=T , ZZ[i,j]*z_j) .
;           4th value: flag if (T) the given solutions make up the whole
;                      set of solutions or (NIL) there may be another solution.
;                      In either case the set of solutions is convex.
; Method:
; Method of Dantzig, see Koulikov book;
; enhancement for degenerate case following Bronstein/Semendjajew.
; [Thanks to all these russian mathematicians!]
(defun simplex (A b c)
  (let (;; m = height of the matrix we are working in.
        (m (length b))
        ;; n = width of the matrix we are working in.
        (n (length c)))
 
    ;; check input:
    (declare (type fixnum m n))
    (assert (typep A `(array * (,m ,n))))

    ;; initialisation:
    (let (;; AA in R^mxn : the tableau we work in
          (AA (let ((h (make-array `(,m ,n))))
                (dotimes (i m)
                  (dotimes (j n)
                    (setf (aref h i j) (rational (aref A i j)))))
                h))
          ;; AB in R^m : the right margin
          (AB (let ((h (make-array m)))
                (dotimes (i m)
                  (setf (aref h i) (rational (elt b i))))
                h))
          ;; AC in R^n : the bottom margin
          (AC (let ((h (make-array n)))
                (dotimes (j n)
                  (setf (aref h j) (rational (elt c j))))
                h))
          ;; AD in R : the bottom right corner
          (AD 0)
          ;; Extend in Boolean : flag if the additional columns (degenerate case) are being used
          (Extend nil)
          ;; AAE in R^mxm : additional columns for the degenerate case
          (AAE nil)
          ;; Zeile in Cons^m : left labels
          (Zeile (let ((h (make-array m)))
                   (dotimes (i m)
                     (setf (aref h i) (cons 'ZO i)))
                   h))
          ;; Spalte in Cons^n : top labels
          (Spalte (let ((h (make-array n)))
                    (dotimes (j n)
                      (setf (aref h j) (cons 'XY j)))
                    h))
          (ZZ (let ((h (make-array `(,m ,m) :initial-element 0)))
                (dotimes (i m)
                  (setf (aref h i i) nil))
                h))
          (Z (make-array m))
          (Y (make-array n))
          (X (make-array n)))

          ; The tableau:
          ;
          ;             | Zeile[0]  Zeile[1]  ... Zeile[n-1]  |
          ; ------------+-------------------------------------+---------
          ; Spalte[0]   |  AA[0,0]   AA[0,1]  ... AA[0,n-1]   |  AB[0]
          ; Spalte[1]   |  AA[1,0]   AA[1,1]  ... AA[1,n-1]   |  AB[1]
          ;   ...       |    ...       ...          ...       |   ...
          ; Spalte[m-1] | AA[m-1,0] AA[m-1,1] ... AA[m-1,n-1] | AB[m-1]
          ; ------------+-------------------------------------+---------
          ;             |   AC[0]     AC[1]   ...   AC[n-1]   |   AD
          ;
          ; Labeling of columns:   0   or   Y
          ;                       ...      ...
          ;                        Z        X
          ;
          ; Labeling of rows:  Z ... 0  or  X ... -Y.
          ;
          ; for all i=0,...,m-1:
          ;   sum(j=0,...,n-1; AA[i,j]*(0 or Y[Spalte[j].Nr])) - AB[i] =
          ;     = (0 or -Y[Zeile[i].Nr])
          ; for all j=0,...,n-1:
          ;   sum(i=0,...,m-1; AA[i,j]*(Z[Zeile[i].Nr] or X[Zeile[i].Nr])) + AC[j] =
          ;     = (Z[Spalte[j].Nr] or X[Spalte[j].Nr])
          ; sum(j=1,...,N; AC[j]*(0 or Y[Spalte[j].Nr])) - AD = <c,y>
          ; sum(i=1,...,M; AB[i]*(Z[Zeile[i].Nr] or X[Zeile[i].Nr])) + AD = <b,z>
          ; These are to be considered as equations in the unknowns X,Y,Z.
          ;
          ; The additional columns - if present - are added at the right.

      (declare (type Zahl-Matrix AA)
               (type Zahl-Vektor AB AC)
               (type Zahl AD))
      (flet
        (; pivots the tableau around the element AA[k,l] with 0<=k<m, 0<=l<n.
         ; The invariant is that before and after pivoting the above
         ; equations hold.
         (pivot (k l)
           (declare (type fixnum k l))
           (let ((r (/ (aref AA k l))))
             (declare (type Zahl r))
             ; column l :
             (progn
               (dotimes (i m)
                 (unless (eql i k)
                   (setf (aref AA i l) (- (* r (aref AA i l)))))))
             (setf (aref AC l) (- (* r (aref AC l))))
             ; everything except row k and column l :
             (dotimes (j n)
               (unless (eql j l)
                 (let ((s (aref AA k j)))
                   (dotimes (i m)
                     (unless (eql i k)
                       (setf (aref AA i j) (+ (aref AA i j) (* s (aref AA i l))))))
                   (setf (aref AC j) (+ (aref AC j) (* s (aref AC l)))))))
             (let ((s (aref AB k)))
               (dotimes (i m)
                 (unless (eql i k)
                   (setf (aref AB i) (+ (aref AB i) (* s (aref AA i l))))))
               (setf AD (+ AD (* s (aref AC l)))))
             (when Extend
               (locally (declare (type Zahl-Matrix AAE))
                 (dotimes (j m)
                   (let ((s (aref AAE k j)))
                     (dotimes (i m)
                       (unless (eql i k)
                         (setf (aref AAE i j) (+ (aref AAE i j) (* s (aref AA i l))))))))))
             ; row k :
             (progn
               (dotimes (j n)
                 (unless (eql j l)
                   (setf (aref AA k j) (* (aref AA k j) r))))
               (setf (aref AB k) (* (aref AB k) r)))
             (when Extend
               (locally (declare (type Zahl-Matrix AAE))
                 (dotimes (j m)
                   (setf (aref AAE k j) (* (aref AAE k j) r)))))
             ; element (k,l) :
             (setf (aref AA k l) r)
             ; swap labels:
             (rotatef (aref Zeile k) (aref Spalte l)))))
        ; Bring the Z variables down (matrix may become smaller):
        (let ((elbar (make-array m :fill-pointer 0))
              (not-elbar (make-array m :fill-pointer 0)))
          ; elbar = set of the eliminatable z,
          ; not-elbar = set of the non-eliminatable z.
          (dotimes (i m)
            ; search maximum of absolute value in row i:
            (let ((hmax 0) (l nil))
              (dotimes (j n)
                (when (eq (car (aref Spalte j)) 'XY)
                  (let ((h (abs (aref AA i j))))
                    (when (> h hmax)
                      (setq hmax h l j)))))
              (if l
                ; AA[i,l] was the maximal element w.r.t. absolute value
                (progn
                  (vector-push i not-elbar)
                  (pivot i l))
                ; trivial row
                (if (zerop (aref AB i))
                  ; Keep this dummy line; it will not change since we will
                  ; pivot only around XY columns and these columns have a 0
                  ; in row i.
                  ; Nonzero elements are only in ZO columns, and these
                  ; will not change.
                  (vector-push i elbar)
                  ; this row makes LP inconsistent -> unsolvable
                  (return-from simplex NIL)))))
          ; Mark the eliminatable row in the ZZ matrix:
          ; The non-eliminatable rows have swapped positions with the X
          ; such that we have Spalte[(cdr Zeile[i])] = (ZO . i) if row i
          ; is non-eliminatable ( <==> (car Zeile[i]) = XY ).
          (dotimes (i0h (fill-pointer elbar))
            (let ((i0 (aref elbar i0h)))
              (setf (aref Z i0) 0)               ; we must set Z[i0]=0 to make the other Z's correct!
              (setf (aref ZZ i0 i0) T)           ; z_i0 is unrestricted
              (dotimes (ih (fill-pointer not-elbar))
                (let* ((i (aref not-elbar ih))   ; we must have (car Zeile[i])=XY
                       (j (cdr (aref Zeile i)))) ; column with which row i was pivoted
                  (setf (aref ZZ i i0) (aref AA i0 j))))))
          ; delete rows: (uses that every not-elbar[i]>=i)
          (dotimes (ih (fill-pointer not-elbar))
            (let ((i (aref not-elbar ih)))
              (unless (eql ih i)
                (dotimes (j n)
                  (setf (aref AA ih j) (aref AA i j)))
                (setf (aref AB ih) (aref AB i)))))
          (setq m (fill-pointer not-elbar))) ; new number of rows = number of the ZO columns
        ; sort columns: bring XY to the left, ZO to the right.
        ; This is used at the end to calculate the non-eliminatable z from the X.
        (let ((l 0) ; left column
              (r (1- n))) ; right column
          (loop
            (unless (< l r)
              (return))
            (cond ((eq (car (aref Spalte l)) 'XY)
                   (incf l))
                  ((eq (car (aref Spalte r)) 'ZO)
                   (decf r))
                  (t ; swap columns r and l
                   (dotimes (i m)
                     (rotatef (aref AA i l) (aref AA i r)))
                   (rotatef (aref AC l) (aref AC r))
                   (rotatef (aref Spalte l) (aref Spalte r))))))
        ; hide these M columns from pivoting:
        (setq n (- n m))
        ; The elements AA[0..m-1,n..n+m-1], AC[n..n+m-1], Spalte[n,n+m-1]
        ; will only be used again at the end of phase 6.
        (let ((Zeile_save (copy-seq Zeile)))
          (flet
            ((SuchePivotZeile (AWZM l)
               ; For a choice set AWZM of rows and a column l choose the
               ; row k such that:
               ; We assume that
               ; for i in AWZM we have 0<=i<m and AB[i]>=0 und AA[i,l]>0.
               ; Among the i in AWZM, k is the one for which the quotient
               ; AB[i]/AA[i,l] is minimal. Should this quotient be =0, or
               ; if Extend=true, then afterwards Extend=true, and the vector
               ; (AB[i]/AA[i,l], AAE[i,1]/AA[i,l], ..., AAE[i,m]/AA[i,l])
               ; has been minimized (lexicographically) among all i in AWZM.
               ; If AWZM is empty, NIL is returned.
               (if (eql (fill-pointer AWZM) 0)
                 NIL
                 (let (k)
                   (unless Extend ; try to choose k
                     (let (hmax)
                       (dotimes (ih (fill-pointer AWZM))
                         (let* ((i (aref AWZM ih))
                                (h (/ (aref AB i) (aref AA i l))))
                           (when (or (eql ih 0) (< h hmax))
                             (setq hmax h k i))))
                       (when (zerop hmax)
                         ; degenerate case
                         (setq Extend T)
                         (setq AAE (make-array `(,m ,m) :initial-element 0))
                         (dotimes (i m) (setf (aref AAE i i) 1)))))
                   (when Extend
                     ; The degenerate case has already been active or has
                     ; emerged now (then the old k may be bad).
                     (let (hmax hmaxe)
                       (dotimes (ih (fill-pointer AWZM))
                         (let ((i (aref AWZM ih)))
                           (let ((h (/ (aref AA i l)))
                                 (he (make-array m)))
                             (dotimes (j m)
                               (setf (aref he j) (* (aref AAE i j) h)))
                             (setq h (* (aref AB i) h))
                             ; (h,he[1],...,he[M]) is the vector of quotients
                             (when (or (eql ih 0)
                                       ; instead of (< h hmax) now lexicographic comparison
                                       ; (h,he[1],...,he[M]) < (hmax,hmaxe[1],...,hmaxe[M]) :
                                       (or (< h hmax)
                                           (and (= h hmax)
                                                (dotimes (ie m NIL)
                                                  (let* ((he_ie (aref he ie))
                                                         (hmaxe_ie (aref hmaxe ie)))
                                                    (when (< he_ie hmaxe_ie)
                                                      (return T))
                                                    (when (> he_ie hmaxe_ie)
                                                      (return NIL)))))))
                               (setq hmax h hmaxe he k i)))))))
                   k))))
            (let ((PZM (make-array m :fill-pointer 0))
                  (p nil))
              ; PZM = set of the i with AB[i]>=0
              ; p = the last i for which AB[i] was being maximized
              (loop ; fill column AB with positive numbers
                #|
                ; throw away roundoff errors:
                (dotimes (ih (fill-pointer PZM))
                  (let ((i (aref PZM ih)))
                    (when (minusp (aref AB i))
                      (setf (aref AB i) 0))))
                |#
                (let ((NZM (make-array m :fill-pointer 0)))
                  ; NZM = set of the i with AB[i]<0
                  ; recalculate PZM and NZM:
                  (let ((old-PZM-count (fill-pointer PZM))) ; old cardinality of PZM
                    (setf (fill-pointer PZM) 0)
                    (dotimes (i m)
                      (if (>= (aref AB i) 0)
                        (vector-push i PZM)
                        (vector-push i NZM)))
                    ; delete the additional columns if PZM really grew
                    ; and the degeneracy perhaps disappeared:
                    (when (> (fill-pointer PZM) old-PZM-count)
                      (setq Extend nil)
                      (setq p nil))
                    ; otherwise PZM remained unchanged, and AB[p]<0 still holds.
                  )
                  (when (eql (fill-pointer NZM) 0)  ; every AB[i]>=0 ?
                    (return))
                  (if p
                    ; use the last p.
                    (when (dotimes (j n t)
                            (when (< (aref AA p j) 0)
                              (return nil)))
                      ; every AA[p,j]>=0 but AB[p]<0
                      ; ==> row makes LP inconsistent ==> unsolvable
                      (return-from simplex NIL))
                    ; choose p: p := the i among those with AB[i]<0
                    ; for which the number of AA[i,j]>=0 is maximal.
                    (let ((countmax -1))
                      (dotimes (ih (fill-pointer NZM))
                        (let ((i (aref NZM ih))
                              (count 0))
                          (dotimes (j n)
                            (when (>= (aref AA i j) 0)
                              (incf count)))
                          (when (> count countmax)
                            (setq countmax count p i))))
                      (when (eql countmax n)
                        ; every AA[p,j]>=0 but AB[p]<0
                        ; ==> row makes LP inconsistent ==> unsolvable
                        (return-from simplex NIL))))
                  ; Now AB[p]<0, and there is a j with AA[p,j]<0.
                  ; Choose l: maximal abs(AA[p,j]) among the j with AA[p,j]<0.
                  (let ((hmin 0) (l nil))
                    (dotimes (j n)
                      (let ((h (aref AA p j)))
                        (when (< h hmin)
                          (setq hmin h l j))))
                    ; build AWZM:
                    (let ((AWZM (make-array m :fill-pointer 0)))
                      (dotimes (ih (fill-pointer PZM))
                        (let ((i (aref PZM ih)))
                          (when (> (aref AA i l) 0)
                            (vector-push i AWZM))))
                      (let ((k (SuchePivotZeile AWZM l)))
                        (if (null k)
                          ; Pivoting around AA[p,l] lets PZM grow at least
                          ; by the element p because:
                          ; for i in PZM we have AB[i]>=0 and
                          ; (because AZdm={}) also AA[i,l]<=0,
                          ; and then afterwards
                          ; AB[i]=AB[i]-AB[p]*AA[i,l]/AA[p,l] >= 0,
                          ;        >=0   <0     <=0     <0
                          ; that is i in PZM again.
                          ; But afterwards we also have
                          ; AB[p]=AB[p]/AA[p,l] (<0/<0) >0,
                          ; therefore p in PZM.
                          (progn
                            (setq Extend nil) ; additional columns aren't needed any more
                            (pivot p l))
                          ; pivot row k chosen, ready for pivoting.
                          ; Pivoting around AA[k,l] does not shrink PZM
                          ; because:
                          ; for i in PZM we have AB[i]>=0.
                          ; If AA[i,l]<=0, we have afterwards
                          ; AB[i]=AB[i]-AB[k]*AA[i,l]/AA[k,l] >=0.
                          ;        >=0   >=0    <=0     >0
                          ; But if AA[i,l]>0, then for every i/=k afterwards
                          ; AB[i]=AA[i,l]*(AB[i]/AA[i,l]-AB[k]/AA[k,l])     >=0
                          ;          >0    >=0 because of the choice of k and i in AWZM
                          ; and for i=k afterwards AB[k]=AB[k]/AA[k,l] (>=0/>0) >=0.
                          ; Therefore afterwards always AB[i]>=0, i.e. i in PZM.
                          (pivot k l))))))))
            ; Now Extend=false, since (fill-pointer PZM) must just have
            ; grown, reaching m.
            ; From now on every AB[i]>=0, and this property remains.
            (loop
              ; search an l with AC[l]<0 :
              (let (l)
                (when
                  (dotimes (j n T)
                    (when (< (aref AC j) 0)
                      (setq l j) (return NIL)))
                  (return)) ; every AC[j]>=0 ==> solvable
                ; AWZM := set of the i with AA[i,l]>0 :
                (let ((AWZM (make-array m :fill-pointer 0)))
                  (dotimes (i m)
                    (when (> (aref AA i l) 0)
                      (vector-push i AWZM)))
                  (let ((k (SuchePivotZeile AWZM l)))
                    (if (null k)
                      ; every AA[i,l]<=0 and AC[l]<0 ==> column makes DP inconsistent
                      (return-from simplex NIL)
                      (pivot k l))))))
                      ; still every AB[i]>=0.
                      ; AD:=AD-AB[k]*AC[l]/AA[k,l] >= AD is not lowered.
                      ;         >=0   <0     >0
            ; Solvable! Build solution:
            (let ((complete t))
              (dotimes (i m)
                (let ((s (aref AB i))
                      (index (cdr (aref Zeile i))))
                  (setf (aref X index) 0 (aref Y index) s)
                  (setq complete (and complete (> s 0)))))
              (dotimes (j n)
                (let ((s (aref AC j))
                      (index (cdr (aref Spalte j))))
                  (setf (aref X index) s (aref Y index) 0)
                  (setq complete (and complete (> s 0)))))
              ; The non-eliminatable z values are calculated from the hidden
              ; parts of AA and AC and the values of X and Y :
              (do ((j n (1+ j)))
                  ((>= j (+ n m)))
                (let ((s (aref AC j)))
                  (dotimes (i m)
                    (setq s (+ s (* (aref AA i j) (aref X (cdr (aref Zeile_save i)))))))
                  (setf (aref Z (cdr (aref Spalte j))) s)))
              (values T (list Y (- AD)) (list X Z ZZ AD) complete))))))))




;;^^
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; macro-centers.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; the macro-center class.
;;;


;; base definition.

(defclass macro-center ()
  ((name :initarg :name
         :accessor name)
   (micro-centers :initarg :micro-centers
                  :initform nil
                  :accessor micro-centers)
   (capacity :initform nil
             :accessor capacity)))
             

(defmethod initialize-instance ((self macro-center) &rest initargs)
  (declare (ignore initargs))
  (call-next-method)
  (unless (slot-boundp self 'name)
    (setf (name self) (intern (format nil "MACRO-CENTER-~A" (incf *macro-center-counter*)))))
  (name self))


;; printing and indenting.

(defmethod print-object ((self macro-center) stream)
  (print-unreadable-object (self stream :type t)
    (princ (name self) stream)))


;; misc.

(defmethod micro-center-p ((micro-center center) (self macro-center))
  (member micro-center (micro-centers self)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; user interface.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;^^
;;;
;;; macro-centers.
;;;


;; all macro-centers.


; (macro-centers)

(defmacro macro-centers ()
  `(impl-macro-centers))

(defun impl-macro-centers ()
  (map-macro-centers #'(lambda (macro-center)
                         (format t "~&~A" (name macro-center))))
  (values))


;; adding and deleting.


; (add-macro-center &optional name &rest micro-names)

(defmacro add-macro-center (&optional name &rest micro-names)
  `(impl-add-macro-center ',name ',micro-names))

(defun impl-add-macro-center (name micro-names)
  (unless (and name (get-macro-center name)
               (every #'get-center micro-names))
    (setq *macro-centers* (nconc *macro-centers* (list (make-instance 'macro-center
                                                         :name name
                                                         :micro-centers (mapcar #'get-center micro-names))))))
  (values))


; (del-macro-centers)

(defmacro del-macro-centers ()
  `(impl-del-macro-centers))

(defun impl-del-macro-centers ()
  (setq *macro-centers* nil)
  (values))


; (del-macro-center name)

(defmacro del-macro-center (name)
  `(impl-del-macro-center ',name))

(defun impl-del-macro-center (name)
  (let ((macro-center (get-macro-center name)))
    (when macro-center
      (setq *macro-centers* (delete macro-center *macro-centers*))))
  (values))



;; capping.


; (macro-caps)

(defmacro macro-caps ()
  `(impl-macro-caps))

(defun impl-macro-caps ()
  (map-macro-centers #'(lambda (macro-center)
                         (format t "~&~A:~A~A" (name macro-center)
                                               #\tab
                                               (capacity macro-center))))
  (values))


; (macro-caps@ name-or-list)

(defmacro macro-caps@ (name-or-list)
  `(impl-macro-caps@ ',name-or-list))

(defun impl-macro-caps@ (name-or-list)
  (when (symbolp name-or-list)
    (setq name-or-list (list name-or-list)))
  (dolist (name name-or-list)
    (let ((macro-center (get-macro-center name)))
      (when macro-center
        (format t "~&~A:~A~A" name #\tab (capacity macro-center)))))
  (values))


; (set-macro-caps num)

(defmacro set-macro-caps (num)
  `(impl-set-macro-caps ,num))

(defun impl-set-macro-caps (num)
  (map-macro-centers #'(lambda (macro-center)
                         (setf (capacity macro-center) num)))
  (values))


; (set-macro-caps@ name-or-list num)

(defmacro set-macro-caps@ (name-or-list num)
  `(impl-set-macro-caps@ ',name-or-list ,num))

(defun impl-set-macro-caps@ (name-or-list num)
  (when (symbolp name-or-list)
    (setq name-or-list (list name-or-list)))
  (dolist (name name-or-list)
    (let ((macro-center (get-macro-center name)))
      (when macro-center
        (setf (capacity macro-center) num))))
  (values))




;;;
;;; centers.
;;;
;;;


;; all centers.


; (centers)

(defmacro centers ()
  `(impl-centers))

(defun impl-centers ()
  (map-centers #'(lambda (center)
                   (format t "~&~A" (name center))))
  (values))


;; adding and deleting.


; (add-center &optional center-name)

(defmacro add-center (&optional center-name)
  `(impl-add-center ',center-name))

(defun impl-add-center (center-name)
  (unless (and center-name (get-center center-name))
    (setq *centers* (nconc *centers* (list (make-instance 'center
                                       :name center-name)))))
  (values))


; (del-centers)

(defmacro del-centers ()
  `(impl-del-centers))

(defun impl-del-centers ()
  (setq *centers* nil)
  (values))


; (del-center center-name)

(defmacro del-center (center-name)
  `(impl-del-center ',center-name))

(defun impl-del-center (center-name)
  (let ((center (get-center center-name)))
    (when center
      (setq *centers* (delete center *centers*))))
  (values))



;; capping.


; (caps)

(defmacro caps ()
  `(impl-caps))

(defun impl-caps ()
  (map-centers #'(lambda (center)
                (format t "~&~A:~A~A" (name center) #\tab (capacity center))))
  (values))


; (caps@ center-name-or-list)

(defmacro caps@ (center-name-or-list)
  `(impl-caps@ ',center-name-or-list))

(defun impl-caps@ (center-name-or-list)
  (when (symbolp center-name-or-list)
    (setq center-name-or-list (list center-name-or-list)))
  (dolist (center-name center-name-or-list)
    (let ((center (get-center center-name)))
      (when center
        (format t "~&~A:~A~A" center-name #\tab (capacity center)))))
  (values))


; (set-caps num)

(defmacro set-caps (num)
  `(impl-set-caps ,num))

(defun impl-set-caps (num)
  (map-centers #'(lambda (center)
                (setf (capacity center) num)))
  (values))


; (set-caps@ center-name-or-list num)

(defmacro set-caps@ (center-name-or-list num)
  `(impl-set-caps@ ',center-name-or-list ,num))

(defun impl-set-caps@ (center-name-or-list num)
  (when (symbolp center-name-or-list)
    (setq center-name-or-list (list center-name-or-list)))
  (dolist (center-name center-name-or-list)
    (let ((center (get-center center-name)))
      (when center
        (setf (capacity center) num))))
  (values))


;; dm.

; (dm &rest class-list)

(defmacro dm (&rest class-list)
  `(impl-dm ',class-list))


; (dm@ center-name-or-list &rest class-list)

(defmacro dm@ (center-name-or-list &rest class-list)
  `(impl-dm@ ',center-name-or-list ',class-list))

(defun impl-dm@ (center-name-or-list class-list)
  (when (symbolp center-name-or-list)
    (setq center-name-or-list (list center-name-or-list)))
  (dolist (center-name center-name-or-list)
    (let ((center (get-center center-name)))
      (when center
        (center-dm center class-list))))
  (print-center-separator)
  (values))


;; productions.


; (matches)

(defmacro matches ()
  `(impl-matches))

(defun impl-matches ()
  (when (pending-dm-actions-p)
    (match))
  (print-macrocycle-banner)
  (map-centers #'(lambda (center)
                 (when (instantiations-p center)
                   (print-center-banner (name center) (cycles center))
                   (map-rhss #'(lambda (p-name node-name fn)
                                 (declare (ignore fn))
                                 (mapc #'(lambda (tok)
                                           (print-instantiation-separator)
                                           (print-instantiation-name p-name)
                                           (print-instantiation-lhs (make-lhs tok)))
                                       (tokens (get-rete-node center node-name))))
                             center))))
  (print-center-separator)
  (values))


; (matches@ center-name-or-list)

(defmacro matches@ (center-name-or-list)
  `(impl-matches@ ',center-name-or-list))

(defun impl-matches@ (center-name-or-list)
  (when (pending-dm-actions-p)
    (match))
  (when (symbolp center-name-or-list)
    (setq center-name-or-list (list center-name-or-list)))
  (print-macrocycle-banner)
  (mapc #'(lambda (center)
            (when (instantiations-p center)
              (print-center-banner (name center) (cycles center))
              (map-rhss #'(lambda (p-name node-name fn)
                            (declare (ignore fn))
                            (mapc #'(lambda (tok)
                                      (print-instantiation-separator)
                                      (print-instantiation-name p-name)
                                      (print-instantiation-lhs (make-lhs tok)))
                                  (tokens (get-rete-node center node-name))))
                        center)))
        (mapcar #'get-center center-name-or-list))
  (print-center-separator)
  (values))


;; specializing.

; (specs &rest dme-classes)

(defmacro specs (&rest dme-classes)
  `(impl-specs ',dme-classes))

(defun impl-specs (dme-classes)
  (map-centers #'(lambda (center)
                (center-specs center dme-classes)))
  (values))


; (specs@ center-name-or-list &rest dme-classes)

(defmacro specs@ (center-name-or-list &rest dme-classes)
  `(impl-specs@ ',center-name-or-list ',dme-classes))

(defun impl-specs@ (center-name-or-list dme-classes)
  (when (symbolp center-name-or-list)
    (setq center-name-or-list (list center-name-or-list)))
  (dolist (center-name center-name-or-list)
    (let ((center (get-center center-name)))
      (when center
        (center-specs center dme-classes))))
  (values))


; (set-specs dme-class num)

(defmacro set-specs (&rest args)
  `(impl-set-specs ,@(let ((pairs nil))
                       (do ((args2 args (cddr args2)))
                           ((null args2))
                         (setq pairs (cons (list 'quote (first args2))
                                           (cons (second args2) pairs))))
                       pairs)))

(defun impl-set-specs (&rest args)
  (map-centers #'(lambda (center)
                (do* ((args2 args (cddr args2)))
                     ((null args2))
                  (center-set-spec center (first args2) (second args2)))))
  (values))
           

; (set-specs@ center-name-or-list dme-class num)

(defmacro set-specs@ (center-name-or-list &rest args)
  `(impl-set-specs@ ',center-name-or-list
                    ,@(let ((pairs nil))
                        (do ((args2 args (cddr args2)))
                            ((null args2))
                          (setq pairs (cons (list 'quote (first args2))
                                            (cons (second args2) pairs))))
                        pairs)))

(defun impl-set-specs@ (center-name-or-list &rest args)
  (when (symbolp center-name-or-list)
    (setq center-name-or-list (list center-name-or-list)))
  (dolist (center-name center-name-or-list)
    (let ((center (get-center center-name)))
      (when center
        (do* ((args2 args (cddr args2)))
             ((null args2))
          (center-set-spec center (first args2) (second args2))))))
  (values))


;; interface macro so users can coveniently define a new class of base-dme.

(defmacro defdmclass (name ancestors . specs)
  (unless (find name ancestors)
    (setq ancestors (append ancestors (list 'base-dme))))
  (let ((slots (subseq specs 0 (position :default-initargs specs)))
        (defaults (rest (member :default-initargs specs))))
    `(progn

       (defclass ,name ,ancestors
         ,(mapcar #'(lambda (slot)
                      (let ((name nil)
                            (initform nil))
                        (cond ((atom slot)
                               (setq name slot))
                              (t
                               (setq name (first slot))
                               (setq initform (second slot))))
                        `(,name :initarg ,(intern (symbol-name name) "KEYWORD")
                                :initform ,initform
                                :accessor ,name)))
                  slots)
         ,@(when defaults
             `(,(push :default-initargs defaults))))

       (defmethod center-dme-spec ((self center) (dme ,name))
         (multiple-value-bind (spec in-p)
                              (gethash ',name (specials self))
           (if in-p
             spec
             (call-next-method))))

       (setf (gethash ',name *dme-slots*)
             (class-slot-names (find-class ',name)))

       ',name)))


;; compiling productions.


; (p prod-name ce-var-list . body)

(defmacro p (prod-name ce-var-list . body)
  `(impl-p ',prod-name ',ce-var-list ',body))

(defun impl-p (prod-name ce-var-list body)
  (map-centers #'(lambda (center)
                 (p-compile center prod-name (copy-tree ce-var-list) (copy-tree body))))
  (values))


; (p@ center-name-or-list prod-name ce-var-list . body)

(defmacro p@ (center-name-or-list prod-name ce-var-list . body)
  `(impl-p@ ',center-name-or-list ',prod-name ',ce-var-list ',body))

(defun impl-p@ (center-name-or-list prod-name ce-var-list body)
  (when (symbolp center-name-or-list)
    (setq center-name-or-list (list center-name-or-list)))
  (dolist (center-name center-name-or-list)
    (let ((center (get-center center-name)))
      (when center
        (p-compile center prod-name (copy-tree ce-var-list) (copy-tree body)))))
  (values))


;; dynamically create new dme class names.
;;
;;^^ Now deprecated because the new SCM doesn't make use of this mechanism.

(defun make-class-name (&rest class-names)
  (cond (class-names
         (setq class-names (mapcar #'(lambda (item)
                                       (typecase item
                                         (symbol item)
                                         (base-dme (class-name (class-of item)))
                                         (t (error "MAKE-CLASS-NAME passed a non-symbol, non-BASE-dmE argument ~A." item))))
                                   class-names))
         (read-from-string (format nil "~A~{-~A~}" (first class-names) (rest class-names))))
        (t
         (error "MAKE-CLASS-NAME passed no arguments."))))


;; dmes.


; (spew source-dme target-dme &rest weights)

(defmacro spew (source target weight)
  `(impl-spew ,source
              ,(typecase target
                 (symbol target)
                 (cons (if (eq (first target) 'get-dme)
                         target
                         `(list (make-instance ,(typecase (first target)
                                                  (symbol `',(first target))
                                                  (list `,(first target)))
                                               ,@(rest target))))))
              ,weight))

(defun impl-spew (source target weight)
  (center-spew source target weight))


; (modify dme slot-name val)

(defmacro modify (dme slot-name val)
  `(impl-modify ,dme ,slot-name ,val))

(defun impl-modify (dme slot-name val)
  (center-modify dme slot-name val)
  (values))


; (add dme &optional (init-act 1.0))

(defmacro add (dme &optional (init-act 1.0))
  `(spew t ,dme ,init-act))


; (del dme)

(defmacro del (dme)
  `(spew ,dme ,dme -1.0))
  

;; inspect and set global variables.


; *tracing-p*

(defmacro tracing-p ()
  `(impl-tracing-p))

(defun impl-tracing-p ()
  *tracing-p*)

(defmacro set-tracing-p (bool)
  `(impl-set-tracing-p ',bool))

(defun impl-set-tracing-p (bool)
  (setq *tracing-p* bool)
  (values))


; *tracing-dm-p*

(defmacro tracing-dm-p ()
  `(impl-tracing-dm-p))

(defun impl-tracing-dm-p ()
  *tracing-dm-p*)

(defmacro set-tracing-dm-p (bool)
  `(impl-set-tracing-dm-p ',bool))

(defun impl-set-tracing-dm-p (bool)
  (setq *tracing-dm-p* bool)
  (values))


; *default-dme-thresh*

(defmacro default-dme-thresh ()
  `(impl-default-dme-thresh))

(defun impl-default-dme-thresh ()
  *default-dme-thresh*)

(defmacro set-default-dme-thresh (thresh)
  `(impl-set-default-dme-thresh ',thresh))

(defun impl-set-default-dme-thresh (thresh)
  (setq *default-dme-thresh* thresh)
  (values))


; *delete-thresh*

(defmacro delete-thresh ()
  `(impl-delete-thresh))

(defun impl-delete-thresh ()
  *delete-thresh*)

(defmacro set-delete-thresh (thresh)
  `(impl-set-delete-thresh ',thresh))

(defun impl-set-delete-thresh (thresh)
  (setq *delete-thresh* thresh)
  (values))


; *default-spec*

(defmacro default-spec ()
  `(impl-default-spec))

(defun impl-default-spec ()
  *default-spec*)

(defmacro set-default-spec (spec)
  `(impl-set-default-spec ',spec))

(defun impl-set-default-spec (spec)
  (setq *default-spec* spec)
  (values))


; *max-act*

(defmacro max-act ()
  `(impl-max-act))

(defun impl-max-act ()
  *max-act*)

(defmacro set-max-act (act)
  `(impl-set-max-act ',act))

(defun impl-set-max-act (act)
  (setq *max-act* act)
  (values))


; *front-act-p*

(defmacro front-act-p ()
  `(impl-front-act-p))

(defun impl-front-act-p ()
  *front-act-p*)

(defmacro set-front-act-p (bool)
  `(impl-set-front-act-p ',bool))

(defun impl-set-front-act-p (bool)
  (setq *front-act-p* bool)
  (values))


; *summ-embeds-p*

(defmacro summ-embeds-p ()
  `(impl-summ-embeds-p))

(defun impl-summ-embeds-p ()
  *summ-embeds-p*)

(defmacro set-summ-embeds-p (bool)
  `(impl-set-summ-embeds-p ',bool))

(defun impl-set-summ-embeds-p (bool)
  (setq *summ-embeds-p* bool)
  (values))


; *elide-nils-p*

(defmacro elide-nils-p ()
  `(impl-elide-nils-p))

(defun impl-elide-nils-p ()
  *elide-nils-p*)

(defmacro set-elide-nils-p (bool)
  `(impl-set-elide-nils-p ',bool))

(defun impl-set-elide-nils-p (bool)
  (setq *elide-nils-p* bool)
  (values))


; *center-outer-p*

(defmacro center-outer-p ()
  `(impl-center-outer-p))

(defun impl-center-outer-p ()
  *center-outer-p*)

(defmacro set-center-outer-p (bool)
  `(impl-set-center-outer-p ',bool))

(defun impl-set-center-outer-p (bool)
  (setq *center-outer-p* bool)
  (values))


;;

(defun init-act-history ()
  (setq *act-history* (mapcar #'list *centers*))
  (values))


;; record segments (of macrocycles).


;

(defun init-segment-history ()
  (setq *segment-history* nil)
  (setq *start-cyc* 1)
  (values))


;

(defmacro end-segment (label)
  `(impl-end-segment ,label))

(defun impl-end-segment (label)
  (push (list label *start-cyc* *cycles*) *segment-history*)
  (setq *start-cyc* (1+ *cycles*))
  (values))


; (reset)

(defmacro reset ()
  `(impl-reset))

(defun impl-reset ()
  (setq *dm* nil)
  (setq *dme-counter* 0)
  (setq *modifies* nil)
  (setq *spews* nil)
  (setq *cycles* 0)
  (init-act-history)
  (init-segment-history)
  (map-centers #'center-reset)
  (values))


;; running simulations.

(defmacro run (&optional (cycs most-positive-fixnum))
  `(impl-run ,cycs))

(defmacro run-to (cycs)
  `(impl-run-to ,cycs))

(defmacro run-off (cycs)
  `(impl-run-off ,cycs))


;; history.

(defmacro history (&key dmes
                        time
                        (measure 'act)
                        (combination 'sum)
                        component-outer-p
                        (center-outer-p *center-outer-p*)
                        verbose-p)
  `(if ',component-outer-p
     (format t "~&WARNING -- The HISTORY command no longer takes the COMPONENT-OUTER-P keyword.  Use CENTER-OUTER-P instead.")
     (impl-history ',(mapcar #'name *centers*) ',dmes ',time ',measure ',combination ',center-outer-p ',verbose-p)))

(defmacro history@ (centers &key dmes
                                 time
                                 (measure 'act)
                                 (combination 'sum)
                                 component-outer-p
                                 (center-outer-p *center-outer-p*)
                                 verbose-p)
  `(if ',component-outer-p
     (format t "~&WARNING -- The HISTORY@ command no longer takes the COMPONENT-OUTER-P keyword.  Use CENTER-OUTER-P instead.")
     (impl-history ',centers ',dmes ',time ',measure ',combination ',center-outer-p ',verbose-p)))

(defun impl-history (centers dmes time measure combination center-outer-p verbose-p)
  (let ((centers (remove nil (typecase centers
                                  (null nil)
                                  (center (list centers))
                                  (symbol (list (get-center centers)))
                                  (list (mapcar #'get-center centers)))))
        (classes (typecase dmes
                   (null nil)
                   (symbol (list dmes))
                   (list dmes))))
    (format t "~&")
    (when verbose-p
      (format t "~%")
      (format t "~&CENTS: ~A" (cond ((null centers)
                                     'n/a)
                                    ((= (length centers) (length *centers*))
                                     'all)
                                    ((= (length centers) 1)
                                     (name (first centers)))
                                    (t
                                     (mapcar #'name centers))))
      (format t "~%DMES: ~A" (cond ((null classes)
                                    'n/a)
                                   ((= (length classes) 1)
                                    (first classes))
                                   (t
                                    classes)))
      (format t "~%TIME: ~A" (or time '*))
      (format t "~%MEASURE: ~A" measure)
      (format t "~%COMBINATION: ~A" combination)
      (format t "~%"))
    (labels ((meas (act cap)
                 (case measure
                   (act act)
                   (prop (if (and (numberp cap)
                                  (not (zerop cap)))
                           (/ act cap)
                           0.0))))
             (comb (act start-cyc end-cyc)
               (case combination
                 (sum act)
                 (avg (let ((cyc-duration (1+ (- end-cyc start-cyc))))
                        (if (zerop cyc-duration)
                          0.0
                          (/ act cyc-duration))))))
             (compute (center class time)
               (unless class
                 (setq class 'total))
               (let ((centers (if center
                                   (list center)
                                   *centers*))
                     (start-cyc (if time
                                   (first time)
                                   1))
                     (end-cyc (if time
                                 (second time)
                                 *cycles*))
                     (total 0.0))
                 (dolist (center centers)
                   (let ((entry (rest (assoc center *act-history*))))
                     (do ((cyc start-cyc (1+ cyc)))
                         ((> cyc end-cyc))
                       (let ((act 0.0))
                         (if (eq class 'total)
                           (incf act (gethash 'total (cdr (assoc cyc entry))))
                           (maphash #'(lambda (cl acts)
                                        (when (subtypep cl class)
                                          (incf act acts)))
;                                          (incf act (cdr acts))))
                                    (cdr (assoc cyc entry))))
                         (incf total (meas act (capacity center)))))))
                 (comb total start-cyc end-cyc))))
      (cond ((null time)
             (format t "~&")
             (cond ((null centers)
                    (dolist (class classes)
                      (format t "~%~A~A~,2F" (shorten class) #\tab (compute nil class nil))))
                   ((null classes)
                    (dolist (center centers)
                      (format t "~%~A~A~,2F" (shorten (name center)) #\tab (compute center nil nil))))
                   (center-outer-p
                    (format t "~%")
                    (dolist (class classes)
                      (format t "~A~A" #\tab (shorten class)))
                    (dolist (center centers)
                      (format t "~%~A" (shorten (name center)))
                      (dolist (class classes)
                        (format t "~A~,2F" #\tab (compute center class nil)))))
                   (t
                    (format t "~%")
                    (dolist (center centers)
                      (format t "~A~A" #\tab (shorten (name center))))
                    (dolist (class classes)
                      (format t "~%~A" (shorten class))
                      (dolist (center centers)
                        (format t "~A~,2F" #\tab (compute center class nil)))))))
            ((null classes)
             (format t "~&~%")
             (dolist (center centers)
               (format t "~A~A" #\tab (shorten (name center))))
             (cond ((symbolp time)
                    (dolist (segment (cond ((member time '(segment segment-end))
                                            (reverse *segment-history*))
                                           ((assoc time *segment-history*)
                                            (list (assoc time *segment-history*)))
                                           (t
                                            nil)))
                      (let ((label (first segment)))
                        (format t "~%~A" (shorten label))
                        (dolist (center centers)
                          (format t "~A~,2F" #\tab (compute center nil (if (eq time 'segment-end)
                                                                            (list (third segment) (third segment))
                                                                            (rest segment))))))))
                   ((and (listp time)
                         (= (length time) 2))
                    (do ((cyc (max 1 (first time)) (+ cyc 1)))
                        ((> cyc (min (second time) *cycles*)))
                      (format t "~%~A" cyc)
                      (dolist (center centers)
                        (format t "~A~,2F" #\tab (compute center nil (list cyc cyc))))))
                   ((numberp time)
                    (do* ((epoch 1 (1+ epoch))
                          (start-cyc 1 (+ start-cyc time))
                          (end-cyc (min (1- (+ start-cyc time)) *cycles*)
                                    (min (1- (+ start-cyc time)) *cycles*)))
                         ((> start-cyc *cycles*))
                      (format t "~%~A" epoch)
                      (dolist (center centers)
                        (format t "~A~,2F" #\tab (compute center nil (list start-cyc end-cyc))))))))
            ((null centers)
             (format t "~&~%")
             (dolist (class classes)
               (format t "~A~A" #\tab (shorten class)))
             (cond ((symbolp time)
                    (dolist (segment (cond ((member time '(segment segment-end))
                                            (reverse *segment-history*))
                                           ((assoc time *segment-history*)
                                            (list (assoc time *segment-history*)))
                                           (t
                                            nil)))
                      (let ((label (first segment)))
                        (format t "~%~A" (shorten label))
                        (dolist (class classes)
                          (format t "~A~,2F" #\tab (compute nil class (if (eq time 'segment-end)
                                                                            (list (third segment) (third segment))
                                                                            (rest segment))))))))
                   ((and (listp time)
                         (= (length time) 2))
                    (do ((cyc (max 1 (first time)) (+ cyc 1)))
                        ((> cyc (min (second time) *cycles*)))
                      (format t "~%~A" cyc)
                      (dolist (class classes)
                        (format t "~A~,2F" #\tab (compute nil class (list cyc cyc))))))
                   ((numberp time)
                    (do* ((epoch 1 (1+ epoch))
                          (start-cyc 1 (+ start-cyc time))
                          (end-cyc (min (1- (+ start-cyc time)) *cycles*)
                                    (min (1- (+ start-cyc time)) *cycles*)))
                         ((> start-cyc *cycles*))
                      (format t "~%~A" epoch)
                      (dolist (class classes)
                        (format t "~A~,2F" #\tab (compute nil class (list start-cyc end-cyc))))))))
            (center-outer-p
             (dolist (center centers)
               (format t "~&~%center: ~A" (name center))
               (format t "~%")
               (dolist (class classes)
                 (format t "~A~A" #\tab (shorten class)))
               (cond ((symbolp time)
                      (dolist (segment (cond ((member time '(segment segment-end))
                                              (reverse *segment-history*))
                                             ((assoc time *segment-history*)
                                              (list (assoc time *segment-history*)))
                                             (t
                                              nil)))
                        (let ((label (first segment)))
                          (format t "~%~A" (shorten label))
                          (dolist (class classes)
                            (format t "~A~,2F" #\tab (compute center class (if (eq time 'segment-end)
                                                                                (list (third segment) (third segment))
                                                                                (rest segment))))))))
                     ((and (listp time)
                           (= (length time) 2))
                      (do ((cyc (max 1 (first time)) (+ cyc 1)))
                          ((> cyc (min (second time) *cycles*)))
                        (format t "~%~A" cyc)
                        (dolist (class classes)
                          (format t "~A~,2F" #\tab (compute center class (list cyc cyc))))))
                     ((numberp time)
                      (do* ((epoch 1 (1+ epoch))
                            (start-cyc 1 (+ start-cyc time))
                            (end-cyc (min (1- (+ start-cyc time)) *cycles*)
                                      (min (1- (+ start-cyc time)) *cycles*)))
                           ((> start-cyc *cycles*))
                        (format t "~%~A" epoch)
                        (dolist (class classes)
                          (format t "~A~,2F" #\tab (compute center class (list start-cyc end-cyc)))))))))
            (t
             (dolist (class classes)
               (format t "~&~%CLASS: ~A" class)
               (format t "~%")
               (dolist (center centers)
                 (format t "~A~A" #\tab (shorten (name center))))
               (cond ((symbolp time)
                      (dolist (segment (cond ((member time '(segment segment-end))
                                              (reverse *segment-history*))
                                             ((assoc time *segment-history*)
                                              (list (assoc time *segment-history*)))
                                             (t
                                              nil)))
                        (let ((label (first segment)))
                          (format t "~%~A" (shorten label))
                          (dolist (center centers)
                            (format t "~A~,2F" #\tab (compute center class (if (eq time 'segment-end)
                                                                                (list (third segment) (third segment))
                                                                                (rest segment))))))))
                     ((and (listp time)
                           (= (length time) 2))
                      (do ((cyc (max 1 (first time)) (+ cyc 1)))
                          ((> cyc (min (second time) *cycles*)))
                        (format t "~%~A" cyc)
                        (dolist (center centers)
                          (format t "~A~,2F" #\tab (compute center class (list cyc cyc))))))
                     ((numberp time)
                      (do* ((epoch 1 (1+ epoch))
                            (start-cyc 1 (+ start-cyc time))
                            (end-cyc (min (1- (+ start-cyc time)) *cycles*)
                                      (min (1- (+ start-cyc time)) *cycles*)))
                           ((> start-cyc *cycles*))
                        (format t "~%~A" epoch)
                        (dolist (center centers)
                          (format t "~A~,2F" #\tab (compute center class (list start-cyc end-cyc))))))))))))
  (values))



;;;
;;; Deprecated commands.
;;;


;; Commands deprecated when "components" were renamed "centers".


; (comps)

(defun comps ()
  (format t "~&WARNING -- The COMPS command has been deprecated.  Use the CENTERS command instead.")
  (impl-centers)
  (values))


; (add-comp &optional comp-name)

(defmacro add-comp (&optional comp-name)
  `(impl-add-comp ',comp-name))

(defun impl-add-comp (comp-name)
  (format t "~&WARNING -- The ADD-COMP command has been deprecated.  Use the ADD-CENTER command instead.")
  (impl-add-center comp-name)
  (values))


; (del-comps)

(defmacro del-comps ()
  `(impl-del-comps))

(defun impl-del-comps ()
  (format t "~&WARNING -- The DEL-COMPS command has been deprecated.  Use the DEL-CENTERS command instead.")
  (impl-del-centers)
  (values))


; (del-comps@ comp-name-or-list)

(defmacro del-comps@ (comp-name-or-list)
  `(impl-del-comp@ ',comp-name-or-list))

(defun impl-del-comps@ (comp-name-or-list)
  (format t "~&WARNING -- The DEL-COMPS@ command has been deprecated.  Use multiple DEL-CENTER commands instead.")
  (when (symbolp comp-name-or-list)
    (setq comp-name-or-list (list comp-name-or-list)))
  (dolist (comp-name comp-name-or-list)
    (impl-del-center comp-name))
  (values))


; *center-outer-p*

(defmacro component-outer-p ()
  `(impl-component-outer-p))

(defun impl-component-outer-p ()
  (format t "~&WARNING -- The COMPONENT-OUTER-P command has been deprecated.  Use the CENTER-OUTER-P command instead.")
  (impl-center-outer-p)
  (values))

(defmacro set-component-outer-p (bool)
  `(impl-set-component-outer-p ',bool))

(defun impl-set-center-outer-p (bool)
  (format t "~&WARNING -- The SET-COMPONENT-OUTER-P command has been deprecated.  Use the SET-CENTER-OUTER-P command instead.")
  (impl-set-center-outer-p bool)
  (values))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; Predicted fMRI time series and functional connectivity between centers.
;;;;
;;;; Pipe the CUs generated by 4caps, which are point estimates of theoretical
;;;; neural computation, through a hemodynamic response function.  The result-
;;;; inng series of predicted activations can be directly compared with an
;;;; observed activation time series as obtained in event-related fMRI studies.
;;;;
;;;; The hemodynamic response function was estimated by Boynton et. al. (1996)
;;;; to be a gamma function with parameters tau=1.25 seconds, n=3, and delta=
;;;; 2.5 seconds.  This was corroborated by Aguirre et. al. (1998).
;;;;
;;;; The TIME-CONVERSION parameter specifies the number of model cycles that
;;;; correspond to one second of real time; it defaults to the value of the
;;;; *TIME-CONVERSION* variables.  It should be specified by the user based on
;;;; the ratio of human response time and model processing time.
;;;;
;;;; References:
;;;;
;;;; Boynton, G. M., Engel, S. A., Glover, G. H., & Heeger, D. J.  (1996).
;;;;   Linear systems analyis of functional magnetic resonance.  The Journal
;;;;   of Neuroscience.  16(13), 4207-4221.
;;;; Aguirre, G. K., Zarahn, E., D'Esposito, M.  (1998).  The variability of
;;;;   human, BOLD hemodynamic responses.  Neuroimage, 8, 360-369.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; General variables and support functions.
;;;


;;

(defparameter *time-conversion* 20)
(defparameter *intervals* 16)



;;;
;;; The time-delayed gamma function.
;;;


;; Support code.

(defparameter *e* 2.7818)

(defun factorial (n)
  (if (zerop n)
    1
    (* n (factorial (- n 1)))))


;; Parameters.

(defparameter *delta* 2.5)
(defparameter *tau* 1.25)
(defparameter *n* 3)


;; The time-delayed gamma density function.

(defun gamma (x)
  (let ((y (- x *delta*)))
    (if (minusp y)
      0
      (/ (* (expt (/ y *tau*) (- *n* 1)) (expt *e* (- (/ y *tau*))))
         (* *tau* (factorial (- *n* 1)))))))



;;;
;;; fMRI functions.
;;;


;;

;;; Convert an array of CUs to an array of fmri activations by convolving each
;;; CU with the hemodynamic response function and summing the resulting curves.
(defun fmri (cu)
  (let* ((n (length cu))
         (fmri (make-array n :initial-element 0)))
    (dotimes (t1 n)
      (dotimes (t2 n)
        (when (>= t1 t2)
          (incf (aref fmri t1) (* (aref cu t2) (gamma (- t1 t2)))))))
    fmri))

(defun fmri-test ()
  (let* ((cu #(1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0))
         (fmri (fmri cu)))
    (dotimes (t1 (length cu))
      (format t "~%~A: ~,2F --> ~,2F" t1 (aref cu t1) (aref fmri t1))))
  (values))

(defun cu-array (cent)
  (let ((cap (capacity cent))
        (record (rest (assoc cent *act-history*)))
        (cu-array (make-array *cycles* :initial-element 0)))
    (when cap
      (dotimes (cyc *cycles*)
        (setf (aref cu-array cyc)
              (/ (gethash 'total (cdr (assoc (1+ cyc) record)) 0) cap))))
    cu-array))

(defun intervalize (raw-array &optional (intervals *intervals*))
  (let* ((raw-length (length raw-array))
         (int-array (make-array intervals :initial-element 0))
         (int-size (ceiling raw-length intervals)))
    (dotimes (int intervals)
      (let ((sum 0)
            (cnt 0))
        (do ((i (* int int-size) (1+ i)))
            ((or (= cnt int-size) (>= i raw-length)))
          (incf sum (aref raw-array i))
          (incf cnt))
        (setf (aref int-array int) (if (zerop cnt)
                                     0
                                     (/ sum cnt)))))
    int-array))



;;;
;;; Statistical functions.
;;;


;;

(defun mean (x)
  (if x
    (/ (reduce #'+ x) (length x))
    0))


;;

(defparameter *lag* 0)

(defun correlation (x1 y1 &optional (lag *lag*))
  (when (plusp lag)
    (setq x1 (subseq x1 0 (- (length x1) lag)))
    (setq y1 (subseq y1 lag)))
  (let* ((xbar (mean x1))	
	 (ybar (mean y1))
	 (x (mapcar #'(lambda (w) (- w xbar)) x1))
	 (y (mapcar #'(lambda (w) (- w ybar)) y1))
	 (sxx (reduce #'+ (mapcar #'* x x)))
	 (sxy (reduce #'+ (mapcar #'* x y)))
	 (syy (reduce #'+ (mapcar #'* y y))))
    (if (or (zerop sxx) (zerop syy)) 	
	nil
	(/ sxy (sqrt (* sxx syy))))))

(defun fishers-z (r)	
  (cond ((= r 1) most-positive-fixnum)
        ((= r -1) most-negative-fixnum)
        (t (* 0.5 (log (/ (+ 1 r)
                          ( - 1 r)))))))



;;;
;;; Top-level commands.
;;;


;; FMRI-HISTORY.

(defmacro fmri-history (&key (delta *delta*)
                             (tau *tau*)
                             (n *n*)
                             (time-conversion *time-conversion*)
                             (intervals *intervals*))
  `(impl-fmri-history ,delta ,tau ,n ,time-conversion ,intervals))

(defun impl-fmri-history (delta tau n time-conversion intervals)
  (let ((*delta* (* delta time-conversion))
        (*tau* (* tau time-conversion))
        (*n* n)
        (*intervals* intervals))
    (let ((int-packets (mapcar #'(lambda (center)
                                   (format t "~&Processing ~A..." (name center))
                                   (cons center (intervalize (fmri (cu-array center)))))
                               *centers*)))
      (format t "~%~A" (shorten 'interval))
      (mapc #'(lambda (int-packet)
                (format t "~A~A" #\tab (shorten (name (car int-packet)))))
            int-packets)
      (dotimes (int intervals)
        (format t "~%~A" (1+ int))
        (mapc #'(lambda (int-packet)
                  (format t "~A~,2F" #\tab (aref (cdr int-packet) int)))
              int-packets))))
  (values))


;; FMRI-HISTORY@

(defmacro fmri-history@ (centers &key (delta *delta*)
                                      (tau *tau*)
                                      (n *n*)
                                      (time-conversion *time-conversion*)
                                      (intervals *intervals*))
  `(impl-fmri-history@ ',centers ,delta ,tau ,n ,time-conversion ,intervals))

(defun impl-fmri-history@ (centers delta tau n time-conversion intervals)
  (let ((*centers* (mapcar #'get-center (if (atom centers)
                                          (list centers)
                                          centers))))
    (impl-fmri-history delta tau n time-conversion intervals)))


;; CONNECTIVITY.

(defmacro connectivity (&key (delta *delta*)
                             (tau *tau*)
                             (n *n*)
                             (time-conversion *time-conversion*)
                             (intervals *intervals*)
                             (lag *lag*))
    `(impl-connectivity ,delta ,tau ,n ,time-conversion ,intervals ,lag))

(defun impl-connectivity (delta tau n time-conversion intervals lag)
  (let ((*delta* (* delta time-conversion))
        (*tau* (* tau time-conversion))
        (*n* n)
        (*intervals* intervals)
        (*lag* lag))
    (let* ((ints (mapcar #'(lambda (center)
                             (format t "~&Processing ~A..." (name center))
                             (cons center (coerce (intervalize (fmri (cu-array center))) 'list)))
                         *centers*))
           (num (length ints))
           (corrs (make-array (list num num) :initial-element nil))
           (zs (make-array (list num num) :initial-element nil)))
      (dotimes (i num)
        (dotimes (j num)
          (when (or (plusp lag)
                    (< i j))
            (let ((corr (correlation (cdr (nth i ints)) (cdr (nth j ints)))))
                   (when corr
                     (setf (aref corrs i j) corr)
                     (setf (aref zs i j) (fishers-z corr)))))))
      (flet ((print-int-array (arr)
               (mapc #'(lambda (int)
                         (format t "~A~A" #\tab (shorten (name (car int)))))
                     ints)
               (dotimes (i num)
                 (format t "~%~A" (shorten (name (car (nth i ints)))))
                 (dotimes (j num)
                   (let ((entry (aref arr i j)))
                     (if entry
                       (format t "~A~,4F" #\tab entry)
                       (format t "~A." #\tab)))))))
        (when (plusp lag)
          (format t "~2%NOTE: The time series for the column center is lagged ~A intervals behind that of the row center." lag))
        (format t "~2%~A" (shorten 'corrs))
        (print-int-array corrs)
        (format t "~2%~A" (shorten 'zs))
        (print-int-array zs))))
  (values))


;; CONNECTIVITY@

(defmacro connectivity@ (centers &key (delta *delta*)
                                       (tau *tau*)
                                       (n *n*)
                                       (time-conversion *time-conversion*)
                                       (intervals *intervals*)
                                       (lag *lag*))
    `(impl-connectivity@ ',centers ,delta ,tau ,n ,time-conversion ,intervals ,lag))

(defun impl-connectivity@ (centers delta tau n time-conversion intervals lag)
  (let ((*centers* (mapcar #'get-center (if (atom centers)
                                          (list centers)
                                          centers))))
    (impl-connectivity delta tau n time-conversion intervals lag)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; initialization.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;
;;; create the initial center.
;;;

(add-center)


