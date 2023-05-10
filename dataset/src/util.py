import math
import random
from enum import Enum

import tarski
from tarski.grounding import LPGroundingStrategy
from tarski.syntax.transform.action_grounding import ground_schema
from tarski.syntax import Atom


class SearchNode:
    def __init__(self, state, parent, action, accumulated_cost=0):
        self.state = state
        self.parent = parent
        self.action = action
        self.accumulated_cost = accumulated_cost

    def extract_path(self):
        if self.action:
            path = self.parent.extract_path() + [self.action]
        else:
            path = []

        return path

    def extract_info(self):
        return self.extract_path(), self.state, self.accumulated_cost, self.extract_succ_node()

    def extract_succ_node(self):
        if not self.parent:
            return None
        if self.parent.parent:
            return self.parent.extract_succ_node()

        return self

    def __lt__(self, other):
        return self.accumulated_cost <= other.accumulated_cost


def make_root_node(state):
    """ Construct the initial root node without parent nor action """
    return SearchNode(state, None, None)


def make_child_node(parent_node, action, state, action_cost=1):
    """ Construct an child search node """
    return SearchNode(state, parent_node, action, parent_node.accumulated_cost + action_cost)


def zero_heuristic(state):
    return 0


def ff_heuristic(state, planner, lw):
    formatedState = ["({})".format(signature[0]) for signature, _ in state.predicate_extensions.items() if
                     signature[0] in [item.predicate.name for item in state.as_atoms()]]
    return planner.eval_hff(lw.formatState(formatedState))

def gc_heuristic(state, planner, lw):
    formatedState = ["({})".format(signature[0]) for signature, _ in state.predicate_extensions.items() if
                     signature[0] in [item.predicate.name for item in state.as_atoms()]]
    return planner.eval_hgc(lw.formatState(formatedState))

def ucb1_select(node, C=math.sqrt(2)):  # assume goal-directed environment so minimal cost
    if len(node.children) == 0:
        return None

    best_score = -float('inf')
    best_children = None

    for child in node.children:
        exploit = - (child.vals / child.visits + child.acc_cost)
        explore = C * math.sqrt(math.log(node.visits) / child.visits)
        score = exploit + explore

        if score > best_score:
            best_score = score
            best_children = [child]
        elif score == best_score:
            best_children.append(child)

    return random.choice(best_children)


def softmax_weights(node):
    weights = {}
    for child in node.children:
        weights[child] = math.exp(- (child.vals / child.visits + child.acc_cost))

    return weights


def softmax_select(node):
    if len(node.children) == 0:
        return None
    ws = softmax_weights(node)
    return random.choices(list(ws.keys()), weights=ws.values())[0]


def greedy_select(node):
    if len(node.children) == 0:
        return None

    best_score = -float('inf')
    best_children = None

    for child in node.children:
        score = - (child.vals / child.visits + child.acc_cost)

        if score > best_score:
            best_score = score
            best_children = [child]
        elif score == best_score:
            best_children.append(child)

    return random.choice(best_children)


class SearchTree:
    def __init__(self, environment, state, rollout_policy=zero_heuristic, tree_policy=ucb1_select, root=None, average_update = True):
        self.environment = environment
        self.average_update = average_update
        self.root = root if root else TreeNode(state, initialization=rollout_policy(state), average_update = self.average_update)
        self.nexpansions = 0
        self.tree_policy = tree_policy
        self.rollout_policy = rollout_policy


    def get_frontier(self):
        """ Choose a leaf node to expand using tree policy"""
        node = self.root
        while node and node.expanded:
            node = self.tree_policy(node)

        return node

    def expand(self, node, repeat_check, replan_visited_states, closed):
        self.nexpansions += 1
        for op, succ in self.environment.successors(node.state):
            if replan_visited_states and succ in replan_visited_states:
                continue

            if repeat_check and succ in closed:
                prev = closed[succ]
                if prev.acc_cost <= node.acc_cost + 1:
                    continue
                else:
                    if prev in prev.parent.children:
                        prev.parent.children.remove(prev)
                        prev.parent.check_deadend()

            init_val = self.rollout_policy(succ)
            new_node = TreeNode(succ, node, op, node.acc_cost + 1, init_val, self.average_update)
            node.children.append(new_node)  # assume uniform cost
            closed[succ] = new_node
            node.update(init_val+1)

        node.expanded = True
        node.check_deadend()

        return closed


class TreeNode:
    def __init__(self, state, parent=None, action=None, acc_cost=0, initialization=0, average_update = True):
        self.state = state
        self.parent = parent
        self.action = action
        self.acc_cost = acc_cost
        self.vals = initialization
        self.visits = 1
        self.children = []
        self.expanded = False
        self.average_update = average_update

    def extract_path(self):
        if self.parent:
            path = self.parent.extract_path() + [self]
        else:
            path = []

        return path

    def extract_info(self):
        return self.extract_path(), self.state, self.acc_cost

    def update(self, val):
        self.visits += 1
        if self.average_update:
            self.vals += val

        else: # best child in goal-directed task (smallest)
            self.vals = self.visits * (min([child.vals/child.visits for child in self.children]) + 1)

        if self.parent:
            self.parent.update(val+1) # assume uniform cost

    def check_deadend(self):
        if self.expanded and len(self.children) == 0:
            self.vals = float('inf')

            if self.parent:
                if self in self.parent.children:
                    self.parent.children.remove(self)
                    self.parent.check_deadend()




class ExitCode(Enum):
    GOAL_FOUND = 1
    TIME_OUT = 2
    DEAD_END = 3
    STOP = 4


def grounding_problem(problem):
    grounder = LPGroundingStrategy(problem)
    # TODO: cannot use naive grounding as it include the sort as well in the result.
    # Current grounding not applicable for unsolvable instance

    # add predicates to grounded language
    grounded_lang = tarski.fstrips.language("grounded")
    for pred in grounder.ground_state_variables():
        grounded_lang.predicate(str(pred))

    grounded_problem = tarski.fstrips.create_fstrips_problem(domain_name='grounded', problem_name='grounded_p',
                                                             language=grounded_lang)

    # add init state
    grounded_init = tarski.model.create(grounded_lang)
    for atom in problem.init.as_atoms():
        grounded_init.add(grounded_lang.get_predicate(str(atom)))

    grounded_problem.init = grounded_init

    # add actions
    for action_name, groundings in grounder.ground_actions().items():
        action = problem.get_action(action_name)
        for grounding in groundings:
            grounded_action = ground_schema(action, grounding)

            if isinstance(grounded_action.precondition, Atom):
                grounded_action.precondition = Atom(
                    grounded_lang.get_predicate(str(grounded_action.precondition)), [])
            else:
                new_formulas = []
                for atom in grounded_action.precondition.subformulas:
                    if isinstance(atom, Atom):
                        new_formulas.append(Atom(grounded_lang.get_predicate(str(atom)), []))
                grounded_action.precondition.subformulas = new_formulas

            for effect in grounded_action.effects:
                effect.atom = Atom(grounded_lang.get_predicate(str(effect.atom)), [])

            grounded_problem.actions[grounded_action.name] = grounded_action

    # add goal
    if isinstance(problem.goal, Atom):
        grounded_problem.goal = Atom(grounded_lang.get_predicate(str(problem.goal)), [])
    else:
        grounded_problem.goal = problem.goal
        new_formulas = []
        for atom in problem.goal.subformulas:
            new_formulas.append(Atom(grounded_lang.get_predicate(str(atom)), []))
        grounded_problem.goal.subformulas = new_formulas

    return grounded_problem
