from tarski.search.operations import is_applicable, progress
from tarski.evaluators.simple import evaluate


class ProblemEnvironment:
    """ Construct a environment based on the problem while initial state and goal states are not specified """

    def __init__(self, problem):
        self.problem = problem
        self.operators = [operator for _, operator in problem.actions.items()]

    def applicable_ops(self, state):
        """ Return a generator with all ground operators that are applicable in the given state. """
        return (op for op in self.operators if self.is_op_applicable(state, op))

    def successors(self, state):
        """ Return a generator with all tuples (op, successor) for successors of the given state. """
        return ((op, self.apply(state, op)) for op in self.applicable_ops(state))

    def apply(self, state, op):
        return progress(state, op) if self.is_op_applicable(state, op) else None

    def is_op_applicable(self, state, op):
        return is_applicable(state, op)


class SearchProblem:
    def __init__(self, environment: ProblemEnvironment, init, goal):
        self.environment = environment
        self.init = init
        self.goal = goal

    def is_goal(self, state):
        return evaluate(self.goal, state)


def create_search_problem(problem):
    return SearchProblem(ProblemEnvironment(problem), problem.init, problem.goal)
