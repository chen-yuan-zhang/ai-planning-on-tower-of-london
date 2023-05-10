import math
import random

from classical_planner.heuristic_planner import HeuristicPlanner
from util import SearchTree, ExitCode, zero_heuristic, greedy_select


def ea_stop_prob(tree, beta=0.2, gamma=0.0001):
    """ stop probability based on evidence accumulation mechanism"""
    if not tree.root.expanded:
        return False

    if len(tree.root.children) == 1:
        return True

    best_score = -float('inf')
    second_score = -float('inf')

    for child in tree.root.children:
        score = - (child.vals / child.visits + child.acc_cost)

        if score >= best_score:
            second_score = best_score
            best_score = score
        elif score > second_score:
            second_score = score

    root_importance = abs(best_score / (best_score - (1 + beta) * second_score))

    x = gamma * tree.nexpansions / root_importance

    return random.random() < x / (x + math.exp(-x))


def ea_stop_det(tree, thershold=1):
    if not tree.root.expanded:
        return False

    best_score = -float('inf')
    second_score = -float('inf')

    for child in tree.root.children:
        score = - (child.vals / child.visits + child.acc_cost)

        if score >= best_score:
            second_score = best_score
            best_score = score
        elif score > second_score:
            second_score = score

    return best_score - second_score > thershold


class AdaptiveLookaheadPlanner(HeuristicPlanner):
    def __init__(self, stop_condition, heuristic_function=zero_heuristic, action_select=greedy_select,
                 max_iterations=-1, repeat_check=False, average_update = True):
        super().__init__(heuristic_function, max_iterations, repeat_check)
        self.stop_condition = stop_condition
        self.action_select = action_select
        self.average_update = average_update

    def search(self, search_problem):
        """ Random choose action from current state"""

        tree = SearchTree(search_problem.environment, search_problem.init, rollout_policy=self.heuristic_function, average_update=self.average_update)
        reach_states = set()
        closed = dict()

        while not self.stop_condition(tree):  # stop condition depends on the search tree
            if 0 <= self.max_iterations <= tree.nexpansions:
                return {"exit_info": ExitCode.TIME_OUT, "selected_succ": self.action_select(tree.root),
                        "time": tree.nexpansions, "reached_states": reach_states}

            node = tree.get_frontier()
            if not node:
                return {"exit_info": ExitCode.DEAD_END, "time": tree.nexpansions}
            reach_states.add(node.state)
            if search_problem.is_goal(node.state):
                return {"exit_info": ExitCode.GOAL_FOUND, "selected_succ": node.extract_path()[
                    0] if node.parent else None, "time": tree.nexpansions, "reached_states": reach_states, "tree": tree}

            tree.expand(node, self.repeat_check, None, closed)

        return {"exit_info": ExitCode.STOP, "selected_succ": self.action_select(tree.root), "time": tree.nexpansions,
                "reached_states": reach_states, "tree": tree}


class MemoryAdaptiveLookaheadPlanner(HeuristicPlanner):
    def __init__(self, stop_condition, heuristic_function=zero_heuristic, action_select=greedy_select,
                 max_iterations=-1, repeat_check=True, average_update = True):
        super().__init__(heuristic_function, max_iterations, repeat_check)
        self.stop_condition = stop_condition
        self.action_select = action_select
        self.average_update = average_update

    def search(self, search_problem, start_tree=None, replan_visited_states=None):
        """ Random choose action from current state"""

        tree = start_tree if start_tree else SearchTree(search_problem.environment, search_problem.init,
                                                        rollout_policy=self.heuristic_function, average_update=self.average_update)
        reach_states = set()
        closed = dict()
        while not self.stop_condition(tree):  # stop condition depends on the search tree
            if 0 <= self.max_iterations <= tree.nexpansions:
                return {"exit_info": ExitCode.TIME_OUT, "selected_succ": self.action_select(tree.root),
                        "time": tree.nexpansions, "reached_states": reach_states}

            node = tree.get_frontier()

            if not node:
                return {"exit_info": ExitCode.DEAD_END, "current_state": tree.root.state, "time": tree.nexpansions}

            reach_states.add(node.state)
            if search_problem.is_goal(node.state):
                root_node = node.extract_path()[0] if node.parent else None
                if root_node:
                    root_node.parent = None
                memory = SearchTree(search_problem.environment, search_problem.init,
                                    rollout_policy=self.heuristic_function,
                                    root=root_node, average_update=self.average_update)
                return {"exit_info": ExitCode.GOAL_FOUND, "selected_succ": root_node, "time": tree.nexpansions,
                        "reached_states": reach_states,
                        "memory": memory}

            closed = tree.expand(node, self.repeat_check, replan_visited_states, closed)

        root_node = self.action_select(tree.root)
        root_node.parent = None
        return {"exit_info": ExitCode.STOP, "selected_succ": root_node, "time": tree.nexpansions,
                "reached_states": reach_states, "memory": SearchTree(search_problem.environment, search_problem.init,
                                                                     rollout_policy=self.heuristic_function,
                                                                     root=root_node, average_update=self.average_update)}
