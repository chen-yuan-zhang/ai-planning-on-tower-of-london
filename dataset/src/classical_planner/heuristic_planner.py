from queue import PriorityQueue, Queue
import random

from planner import Planner
from util import make_child_node, make_root_node, ExitCode
from util import zero_heuristic


class HeuristicPlanner(Planner):
    def __init__(self, heuristic_function, max_iterations, repeat_check):
        super().__init__(max_iterations, repeat_check)
        self.heuristic_function = heuristic_function


class AStarSearch(HeuristicPlanner):
    def __init__(self, heuristic_function=zero_heuristic, max_iterations=-1, repeat_check=True):
        super().__init__(heuristic_function, max_iterations, repeat_check)

    def search(self, search_problem):
        """ AStar Search"""

        iteration = 0
        current_node = None
        openlist = PriorityQueue()
        openlist.put((self.heuristic_function(search_problem.init), make_root_node(search_problem.init)))
        closed = dict()
        while not openlist.empty():
            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_info(), "time": iteration}

            val, current_node = openlist.get()

            if self.repeat_check and current_node.state in closed and closed[current_node.state] <= val:
                continue

            closed[current_node.state] = val

            if search_problem.is_goal(current_node.state):
                return {"exit_info": ExitCode.GOAL_FOUND, "node_info": current_node.extract_info(), "time": iteration}

            iteration += 1

            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.put((self.heuristic_function(succ) + current_node.accumulated_cost + 1,
                              make_child_node(current_node, op, succ)))  # assume op cost is uniform

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_info(), "time": iteration}

    def search_full_sol(self, search_problem):
        """ AStar Search"""

        iteration = 0
        current_node = None
        openlist = PriorityQueue()
        openlist.put((self.heuristic_function(search_problem.init), make_root_node(search_problem.init)))
        closed = dict()
        goal_val = -1
        nodes_info = []
        while not openlist.empty():

            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_info(), "time": iteration}

            val, current_node = openlist.get()
            if 0 <= goal_val < val:
                return {"exit_info": ExitCode.GOAL_FOUND, "nodes_info": nodes_info, "time": iteration}

            if self.repeat_check and current_node.state in closed and closed[current_node.state] <= val:
                continue

            closed[current_node.state] = val

            if search_problem.is_goal(current_node.state):
                goal_val = val
                nodes_info.append(current_node.extract_info())
                print("Goal Found!")

            iteration += 1

            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.put((self.heuristic_function(succ) + current_node.accumulated_cost + 1,
                              make_child_node(current_node, op, succ)))  # assume op cost is uniform

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_info(), "time": iteration}


class BestFirstSearch(HeuristicPlanner):
    def __init__(self, heuristic_function=zero_heuristic, max_iterations=-1, repeat_check=True):
        super().__init__(heuristic_function, max_iterations, repeat_check)

    def search(self, search_problem):
        """ Best First (Greedy) Search"""

        iteration = 0
        current_node = None
        openlist = PriorityQueue()
        openlist.put((self.heuristic_function(search_problem.init), make_root_node(search_problem.init)))
        closed = dict()
        while not openlist.empty():
            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_info(), "time": iteration}

            val, current_node = openlist.get()

            if self.repeat_check and current_node.state in closed and closed[current_node.state] <= val:
                continue

            closed[current_node.state] = val

            if search_problem.is_goal(current_node.state):
                return {"exit_info": ExitCode.GOAL_FOUND, "node_info": current_node.extract_info(), "time": iteration}

            iteration += 1

            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.put((self.heuristic_function(succ),
                              make_child_node(current_node, op, succ)))  # assume op cost is uniform

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_info(), "time": iteration}

class FixedDepthLookaheadPlanner(HeuristicPlanner):
    def __init__(self, stop_depth, heuristic_function=zero_heuristic, max_iterations=-1, repeat_check=False):
        super().__init__(heuristic_function, max_iterations, repeat_check)
        self.stop_depth = stop_depth

    def search(self, search_problem):
        """ Fixed Depth Lookahead Search"""

        iteration = 0
        current_node = None
        openlist = Queue()
        openlist.put((make_root_node(search_problem.init), 0))
        closed = set()
        best_nodes = []
        best_val = float("inf")

        while not openlist.empty():
            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_succ_node(),
                        "time": iteration, "reached_states": closed}

            current_node, depth = openlist.get()

            if depth > self.stop_depth:  # return result
                best_node = random.choice(best_nodes)
                return {"exit_info": ExitCode.STOP, "node_info": best_node.extract_succ_node(), "time": iteration,
                        "reached_states": closed}

            if self.repeat_check and current_node.state in closed:
                continue

            closed.add(current_node.state)

            if search_problem.is_goal(current_node.state):
                return {"exit_info": ExitCode.GOAL_FOUND, "node_info": current_node.extract_succ_node(),
                        "time": iteration, "reached_states": closed, "remaining_length": depth}

            if depth == self.stop_depth:  # leaf node
                val = self.heuristic_function(current_node.state)
                if val < best_val:
                    best_nodes = [current_node]
                    best_val = val
                elif val == best_val:
                    best_nodes.append(current_node)

            iteration += 1

            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.put((make_child_node(current_node, op, succ), depth + 1))

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_succ_node(), "time": iteration,
                "reached_states": closed}

    def search_full_sol(self, search_problem):
        """ Fixed Depth Lookahead Search"""

        iteration = 0
        current_node = None
        openlist = Queue()
        openlist.put((make_root_node(search_problem.init), 0))
        closed = set()
        best_nodes = []
        best_val = float("inf")
        ans_d = -1
        nodes_info = []
        while not openlist.empty():
            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_succ_node(),
                        "time": iteration, "reached_states": closed}

            current_node, depth = openlist.get()

            if 0 <= ans_d < depth:
                return {"exit_info": ExitCode.GOAL_FOUND, "nodes_info": nodes_info, "time": iteration}

            if depth > self.stop_depth:  # return result
                return {"exit_info": ExitCode.STOP, "nodes_info": [node.extract_info() for node in best_nodes], "time": iteration,
                        "reached_states": closed}

            if self.repeat_check and current_node.state in closed:
                continue

            closed.add(current_node.state)

            if search_problem.is_goal(current_node.state):
                ans_d = depth
                nodes_info.append(current_node.extract_info())
                print("Goal Found!")

            if depth == self.stop_depth:  # leaf node
                val = self.heuristic_function(current_node.state)
                if val < best_val:
                    best_nodes = [current_node]
                    best_val = val
                elif val == best_val:
                    best_nodes.append(current_node)

            iteration += 1

            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.put((make_child_node(current_node, op, succ), depth + 1))

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_succ_node(), "time": iteration,
                "reached_states": closed}