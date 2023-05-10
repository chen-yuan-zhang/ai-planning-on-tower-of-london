import random

from planner import Planner
from util import make_child_node, make_root_node, ExitCode
from queue import Queue


class BlindPlanner(Planner):
    pass


class BreadthFirstSearch(BlindPlanner):
    def __init__(self, max_iterations=-1, repeat_check=True):
        super().__init__(max_iterations, repeat_check)

    def search(self, search_problem):
        """ Breadth First Search"""

        iteration = 0
        current_node = None
        openlist = Queue()
        openlist.put(make_root_node(search_problem.init))
        closed = set()
        while not openlist.empty():
            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_info(), "time": iteration}

            current_node = openlist.get()

            if self.repeat_check and current_node.state in closed:
                continue

            closed.add(current_node.state)

            if search_problem.is_goal(current_node.state):
                return {"exit_info": ExitCode.GOAL_FOUND, "node_info": current_node.extract_info(), "time": iteration}

            iteration += 1

            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.put(make_child_node(current_node, op, succ))

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_info(), "time": iteration}

    def search_full_sol(self, search_problem):
        """ Breadth First Search"""

        iteration = 0
        current_node = None
        openlist = Queue()
        openlist.put((make_root_node(search_problem.init), 0))
        closed = set()
        ans_d = -1
        nodes_info = []
        while not openlist.empty():
            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_info(), "time": iteration}

            current_node, d = openlist.get()
            if 0 <= ans_d < d:
                return {"exit_info": ExitCode.GOAL_FOUND, "nodes_info": nodes_info, "time": iteration}

            if self.repeat_check and current_node.state in closed:
                continue

            closed.add(current_node.state)

            if search_problem.is_goal(current_node.state):
                ans_d = d
                nodes_info.append(current_node.extract_info())
                print("Goal Found!")

            iteration += 1

            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.put((make_child_node(current_node, op, succ), d + 1))

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_info(), "time": iteration}


class RandomWalk(BlindPlanner):
    def __init__(self, max_iterations=-1, repeat_check=True):
        super().__init__(max_iterations, repeat_check)

    def search(self, search_problem):
        """ Random choose action from current state"""

        iteration = 0
        current_node = None
        openlist = [make_root_node(search_problem.init)]
        closed = set()
        while openlist:
            if 0 <= self.max_iterations <= iteration:
                return {"exit_info": ExitCode.TIME_OUT, "node_info": current_node.extract_info(), "time": iteration}

            current_node = random.choice(openlist)

            if self.repeat_check and current_node.state in closed:
                openlist.remove(current_node)
                continue

            closed.add(current_node.state)

            if search_problem.is_goal(current_node.state):
                return {"exit_info": ExitCode.GOAL_FOUND, "node_info": current_node.extract_info(), "time": iteration}

            iteration += 1
            openlist = []
            for op, succ in search_problem.environment.successors(current_node.state):
                openlist.append(make_child_node(current_node, op, succ))

        return {"exit_info": ExitCode.DEAD_END, "node_info": current_node.extract_info(), "time": iteration}
