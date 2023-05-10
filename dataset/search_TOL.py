import math, sys

from tarski.io import PDDLReader
sys.path.append('/home/student.unimelb.edu.au/chenyuanz/py_projects/planner_pddl/src')

from heuristic_functions import LAPKTarski, Planner
from problem import create_search_problem, SearchProblem, ProblemEnvironment
from classical_planner.heuristic_planner import AStarSearch, BestFirstSearch, FixedDepthLookaheadPlanner
from classical_planner.blind_planner import BreadthFirstSearch as BFS
from timing_planner.adaptive_lookahead_planner import AdaptiveLookaheadPlanner, ea_stop_prob, ea_stop_det, \
    MemoryAdaptiveLookaheadPlanner
from util import ExitCode, gc_heuristic
from functools import partial
import os
import json

def main():
    problem_id = 0
    while os.path.exists("TOLdataset/TOL_" + str(problem_id)):
        # use old PDDL model (without handempty predicate)

        folder = "TOLdataset/TOL_" + str(problem_id)
        print(folder)
        domain = folder + "/domain.pddl"
        instance = folder + "/problem.pddl"

        with open(folder + "/info.json") as f:
            info_dict = json.load(f)

        reader = PDDLReader(raise_on_error=True)
        reader.parse_domain(domain)
        problem = reader.parse_instance(instance)

        searchProblem = create_search_problem(problem)

        """setup planner for heuristic computation"""
        planner = Planner()
        lw = LAPKTarski.writer()
        lw.groundedTarski(planner, problem)
        planner.setup()

        # """BFS"""
        # bfs = BFS(repeat_check=False)
        # result = bfs.search_full_sol(searchProblem)
        #
        # succ_dict = {}
        # for info in result['nodes_info']:
        #     if (info[-1]):
        #         succ_dict[str(info[-1].state)] = succ_dict.get(str(info[-1].state), 0) + 1
        #
        # info_dict['optimal_cost'] = result['nodes_info'][0][2]
        # info_dict['action_count(BFS)'] = succ_dict
        # info_dict['time(BFS)'] = result['time']
        #
        # """ASTAR"""
        # astar= AStarSearch(heuristic_function=partial(gc_heuristic, planner=planner, lw=lw), repeat_check=False)
        # result = astar.search_full_sol(searchProblem)
        #
        # succ_dict = {}
        # for info in result['nodes_info']:
        #     if (info[-1]):
        #         succ_dict[str(info[-1].state)] = succ_dict.get(str(info[-1].state), 0) + 1
        #
        # info_dict['action_count(ASTAR)'] = succ_dict
        # info_dict['time(ASTAR)'] = result['time']
        #
        # """GBFS"""
        # gbfs = BestFirstSearch(heuristic_function=partial(gc_heuristic, planner=planner, lw=lw), repeat_check=True)
        # result = gbfs.search(searchProblem)
        #
        # if result['node_info'][3]:
        #     info_dict['action_count(GBFS)'] = {str(result['node_info'][3].state): 1}
        # else:
        #     info_dict['action_count(GBFS)'] = None
        #
        # info_dict['time(GBFS)'] = result['time']

        # """LH"""
        # for i in range(1,8):
        #     lh= FixedDepthLookaheadPlanner(stop_depth = i, heuristic_function=partial(gc_heuristic, planner=planner, lw=lw), repeat_check=False)
        #     result = lh.search_full_sol(searchProblem)
        #
        #     succ_dict = {}
        #     for info in result['nodes_info']:
        #         if (info[-1]):
        #             succ_dict[str(info[-1].state)] = succ_dict.get(str(info[-1].state), 0) + 1
        #
        #     info_dict['action_count(LH' + str(i) + ')'] = succ_dict
        #     info_dict['time(LH' + str(i) + ')'] = result['time']

        """a-lh"""
        alh = AdaptiveLookaheadPlanner(ea_stop_det, heuristic_function=partial(gc_heuristic, planner=planner, lw=lw), average_update=False)
        result = alh.search(searchProblem)
        action_count=[]

        for child in result['tree'].root.children:
            action_count.append((str(child.state), math.exp(- (child.vals / child.visits + child.acc_cost))))

        info_dict['action_count(ALH)'] = action_count
        info_dict['time(ALH)'] = result['time']

        with open(folder + "/info.json", 'w') as f:
            json.dump(info_dict, f)

        problem_id += 1


if __name__ == "__main__":
    main()
