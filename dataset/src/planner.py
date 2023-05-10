from problem import SearchProblem

class Planner:
    """ A base class for all planners """
    def __init__(self, max_iterations, repeat_check):
        self.max_iterations = max_iterations
        self.repeat_check = repeat_check

    def search(self, search_problem: SearchProblem):
        pass