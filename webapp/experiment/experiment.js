/* ************************************ */
/* Define helper functions */
/* ************************************ */
function assessPerformance() {
  /* Function to calculate the "credit_var", which is a boolean used to
  credit individual experiments in expfactory.
   */
  var experiment_data = jsPsych.data.getTrialsOfType('single-stim-button');
  var missed_count = 0;
  var trial_count = 0;
  var rt_array = [];
  var rt = 0;
  var avg_rt = -1;
  //record choices participants made
  for (var i = 0; i < experiment_data.length; i++) {
    trial_count += 1
    rt = experiment_data[i].rt
    if (rt == -1) {
      missed_count += 1
    } else {
      rt_array.push(rt)
    }
  }
  //calculate average rt
  if (rt_array.length !== 0) {
    avg_rt = math.median(rt_array)
  } else {
    avg_rt = -1
  }
  credit_var = (avg_rt > 100)
  jsPsych.data.addDataToLastTrial({"credit_var": credit_var})
}

var getStim = function() {
  var ref_board = makeBoard('your_board', curr_placement, 'ref')
  var target_board = makeBoard('peg_board', goal_boards[problems[problem_i]])
  var canvas = '<div class = tol_canvas><div class="tol_vertical_line"></div></div>'
  var hold_box;
  if (held_ball !== 0) {
    ball = colors[held_ball - 1]
    hold_box = '<div class = tol_hand_box><div class = "tol_hand_ball tol_' + ball +
      '"><div class = tol_ball_label>' + ball[0] +
      '</div></div></div><div class = tol_hand_label><strong>Ball in Hand</strong></div>'
  } else {
    hold_box =
      '<div class = tol_hand_box></div><div class = tol_hand_label><strong>Ball in Hand</strong></div>'
  }
  return canvas + ref_board + target_board + hold_box
}

var getPractice = function() {
  var ref_board = makeBoard('your_board', curr_placement, 'ref')
  var target_board = makeBoard('peg_board', example_problem3)
  var canvas = '<div class = tol_canvas><div class="tol_vertical_line"></div></div>'
  var hold_box;
  if (held_ball !== 0) {
    ball = colors[held_ball - 1]
    hold_box = '<div class = tol_hand_box><div class = "tol_hand_ball tol_' + ball +
      '"><div class = tol_ball_label>' + ball[0] +
      '</div></div></div><div class = tol_hand_label><strong>Ball in Hand</strong></div>'
  } else {
    hold_box =
      '<div class = tol_hand_box></div><div class = tol_hand_label><strong>Ball in Hand</strong></div>'
  }
  return canvas + ref_board + target_board + hold_box
}

var getFBfull = function() {
  var data = jsPsych.data.getLastTrialData()
  var target = data.target
  var isequal = true
  correct = 0
  for (var i = 0; i < target.length; i++) {
    isequal = arraysEqual(target[i], data.current_position[i])
    if (isequal === false) {
      break;
    }
  }
  var feedback;
  if (isequal === true) {
    if (data.num_moves_made === data.min_moves) {
      feedback = "Congratulations! You solved it using the minimal number of moves!"
      correct = 1
    }
    else{
      feedback = "You solved it but used a few extra moves. Try to use the minimal number of moves next time!"
      correct = 2
    }
  } else {
    feedback = "Didn't get that one."
  }
  var ref_board = makeBoard('your_board', curr_placement)
  var target_board = makeBoard('peg_board', target)
  var canvas = '<div class = tol_canvas><div class="tol_vertical_line"></div></div>'
  var feedback_box = '<div class = tol_feedbackbox><p class = center-text>' + feedback +
    '</p></div>'
  return canvas + ref_board + target_board + feedback_box
}

var getFB = function() {
  var data = jsPsych.data.getLastTrialData()
  var target = data.target
  var isequal = true
  correct = 0
  for (var i = 0; i < target.length; i++) {
    isequal = arraysEqual(target[i], data.current_position[i])
    if (isequal === false) {
      break;
    }
  }
  var feedback;
  if (isequal === true) {
    if (data.num_moves_made === data.min_moves) {
      feedback = "Congratulations! You got it!"
      correct = 1
    }
    else{
      feedback = "Congratulations! You got it!"
      correct = 2
    }
  } else {
    feedback = "Didn't get that one."
  }
  var ref_board = makeBoard('your_board', curr_placement)
  var target_board = makeBoard('peg_board', target)
  var canvas = '<div class = tol_canvas><div class="tol_vertical_line"></div></div>'
  var feedback_box = '<div class = tol_feedbackbox><p class = center-text>' + feedback +
    '</p></div>'
  return canvas + ref_board + target_board + feedback_box
}

var getTime = function() {
  if ((time_per_trial - time_elapsed) > 0) {
    return time_per_trial - time_elapsed
  } else {
    return 1
  }

}

var getText = function() {
  return '<div class = centerbox><p class = center-block-text>About to start problem ' + (problem_i + 2) + ' of ' + problems_total +
    '. Press <strong>enter</strong> to begin.</p></div>'
}

var getText_full = function() {
  return '<div class = centerbox><p class = center-block-text>About to start problem ' + (problem_i + 2) + ' of ' + problems_total +
    '. <strong>Before moving any of the balls, remember figure out a complete set of moves in your head that will make your board look like the target board.</strong> Press <strong>enter</strong> to begin. </p></div>'
}

var pegClick = function(peg_id) {
  var choice = Number(peg_id.slice(-1)) - 1
  var peg = curr_placement[choice]
  var ball_location = 0
  if (held_ball === 0) {
    for (var i = peg.length - 1; i >= 0; i--) {
      if (peg[i] !== 0) {
        held_ball = peg[i]
        peg[i] = 0
        num_moves += 1
        break;
      }
    }
  } else {
    var open_spot = peg.indexOf(0)
    if (open_spot != -1) {
      peg[open_spot] = held_ball
      held_ball = 0
    }
  }
}

var makeBoard = function(container, ball_placement, board_type) {
  var board = '<div class = tol_' + container + '><div class = tol_base></div>'
  if (container == 'your_board') {
    board += '<div class = tol_board_label><strong>Your Board</strong></div>'
  } else {
    board += '<div class = tol_board_label><strong>Target Board</strong></div>'
  }
  for (var p = 0; p < 3; p++) {
    board += '<div id = tol_peg_' + (p + 1) + '><div class = tol_peg></div></div>' //place peg
      //place balls
    if (board_type == 'ref') {
      if (ball_placement[p][0] === 0 & held_ball === 0) {
        board += '<div id = tol_peg_' + (p + 1) + ' onclick = "pegClick(this.id)">'
      } else if (ball_placement[p].slice(-1)[0] !== 0 & held_ball !== 0) {
        board += '<div id = tol_peg_' + (p + 1) + ' onclick = "pegClick(this.id)">'
      } else {
        board += '<div class = special id = tol_peg_' + (p + 1) + ' onclick = "pegClick(this.id)">'
      }
    } else {
      board += '<div id = tol_peg_' + (p + 1) + ' >'
    }
    var peg = ball_placement[p]
    for (var b = 0; b < peg.length; b++) {
      if (peg[b] !== 0) {
        ball = colors[peg[b] - 1]
        board += '<div class = "tol_ball tol_' + ball + '"><div class = tol_ball_label>' + ball[0] +
          '</div></div>'
      }
    }
    board += '</div>'
  }
  board += '</div>'
  return board
}

var arraysEqual = function(arr1, arr2) {
  if (arr1.length !== arr2.length)
    return false;
  for (var i = arr1.length; i--;) {
    if (arr1[i] !== arr2[i])
      return false;
  }
  return true;
}

var getInstructFeedback = function() {
  return '<div class = centerbox><p class = center-block-text>' + feedback_instruct_text +
    '</p></div>'
}

/* ************************************ */
/* Define experimental variables */
/* ************************************ */
// generic task variables
var sumInstructTime = 0 //ms
var instructTimeThresh = 0 ///in seconds
var credit_var = true
var problems_total = 39

// task specific variables
var correct = false
var exp_stage = 'practice'
var colors = ['Green', 'Red', 'Blue']
var problem_i = 0
var time_per_trial = 120000 //time per trial in millseconds
var time_elapsed = 0 //tracks time for a problem
var num_moves = 0 //tracks number of moves for a problem
  /*keeps track of peg board (where balls are). Lowest ball is the first value for each peg.
  So the initial_placement has the 1st ball and 2nd ball on the first peg and the third ball on the 2nd peg.
  */
  // make Your board
var curr_placement = [
  [1, 2, 0],
  [3, 0],
  [0]
]
var example_problem1 = [
  [1, 2, 0],
  [0, 0],
  [3]
]
var example_problem2 = [
  [1, 0, 0],
  [3, 0],
  [2]
]
var example_problem3 = [
  [0, 0, 0],
  [3, 2],
  [1]
]
var ref_board = makeBoard('your_board', curr_placement)
var init_boards = {'TOL_87': [[3, 0, 0], [1, 2], [0]], 'TOL_18': [[1, 2, 3], [0, 0], [0]], 'TOL_190': [[0, 0, 0], [2, 3], [1]], 'TOL_144': [[3, 0, 0], [2, 0], [1]], 'TOL_155': [[3, 0, 0], [2, 0], [1]], 'TOL_120': [[2, 3, 0], [0, 0], [1]], 'TOL_45': [[2, 3, 0], [1, 0], [0]], 'TOL_57': [[2, 3, 0], [1, 0], [0]], 'TOL_161': [[3, 0, 0], [2, 0], [1]], 'TOL_65': [[2, 3, 0], [1, 0], [0]], 'TOL_11': [[1, 2, 3], [0, 0], [0]], 'TOL_66': [[2, 3, 0], [1, 0], [0]], 'TOL_25': [[1, 2, 3], [0, 0], [0]], 'TOL_166': [[3, 0, 0], [2, 0], [1]], 'TOL_150': [[3, 0, 0], [2, 0], [1]], 'TOL_178': [[3, 0, 0], [2, 0], [1]], 'TOL_207': [[0, 0, 0], [2, 3], [1]], 'TOL_41': [[2, 3, 0], [1, 0], [0]], 'TOL_14': [[1, 2, 3], [0, 0], [0]], 'TOL_71': [[2, 3, 0], [1, 0], [0]], 'TOL_101': [[3, 0, 0], [1, 2], [0]], 'TOL_63': [[2, 3, 0], [1, 0], [0]], 'TOL_50': [[2, 3, 0], [1, 0], [0]], 'TOL_116': [[2, 3, 0], [0, 0], [1]], 'TOL_103': [[3, 0, 0], [1, 2], [0]], 'TOL_88': [[3, 0, 0], [1, 2], [0]], 'TOL_36': [[2, 3, 0], [1, 0], [0]], 'TOL_28': [[1, 2, 3], [0, 0], [0]], 'TOL_69': [[2, 3, 0], [1, 0], [0]], 'TOL_162': [[3, 0, 0], [2, 0], [1]], 'TOL_171': [[3, 0, 0], [2, 0], [1]], 'TOL_99': [[3, 0, 0], [1, 2], [0]], 'TOL_172': [[3, 0, 0], [2, 0], [1]], 'TOL_113': [[2, 3, 0], [0, 0], [1]], 'TOL_132': [[2, 3, 0], [0, 0], [1]], 'TOL_24': [[1, 2, 3], [0, 0], [0]], 'TOL_97': [[3, 0, 0], [1, 2], [0]], 'TOL_46': [[2, 3, 0], [1, 0], [0]], 'TOL_157': [[3, 0, 0], [2, 0], [1]], 'TOL_6': [[1, 2, 3], [0, 0], [0]], 'TOL_122': [[2, 3, 0], [0, 0], [1]], 'TOL_164': [[3, 0, 0], [2, 0], [1]], 'TOL_56': [[2, 3, 0], [1, 0], [0]], 'TOL_80': [[3, 0, 0], [1, 2], [0]], 'TOL_44': [[2, 3, 0], [1, 0], [0]], 'TOL_134': [[2, 3, 0], [0, 0], [1]], 'TOL_135': [[2, 3, 0], [0, 0], [1]], 'TOL_146': [[3, 0, 0], [2, 0], [1]], 'TOL_192': [[0, 0, 0], [2, 3], [1]], 'TOL_203': [[0, 0, 0], [2, 3], [1]], 'TOL_208': [[0, 0, 0], [2, 3], [1]], 'TOL_213': [[0, 0, 0], [2, 3], [1]], 'TOL_186': [[0, 0, 0], [2, 3], [1]], 'TOL_130': [[2, 3, 0], [0, 0], [1]], 'TOL_129': [[2, 3, 0], [0, 0], [1]], 'TOL_83': [[3, 0, 0], [1, 2], [0]], 'TOL_40': [[2, 3, 0], [1, 0], [0]], 'TOL_118': [[2, 3, 0], [0, 0], [1]], 'TOL_13': [[1, 2, 3], [0, 0], [0]], 'TOL_167': [[3, 0, 0], [2, 0], [1]], 'TOL_211': [[0, 0, 0], [2, 3], [1]], 'TOL_37': [[2, 3, 0], [1, 0], [0]], 'TOL_115': [[2, 3, 0], [0, 0], [1]], 'TOL_197': [[0, 0, 0], [2, 3], [1]], 'TOL_212': [[0, 0, 0], [2, 3], [1]], 'TOL_74': [[3, 0, 0], [1, 2], [0]], 'TOL_107': [[3, 0, 0], [1, 2], [0]], 'TOL_94': [[3, 0, 0], [1, 2], [0]], 'TOL_191': [[0, 0, 0], [2, 3], [1]], 'TOL_128': [[2, 3, 0], [0, 0], [1]], 'TOL_23': [[1, 2, 3], [0, 0], [0]], 'TOL_60': [[2, 3, 0], [1, 0], [0]], 'TOL_43': [[2, 3, 0], [1, 0], [0]], 'TOL_105': [[3, 0, 0], [1, 2], [0]], 'TOL_73': [[3, 0, 0], [1, 2], [0]], 'TOL_4': [[1, 2, 3], [0, 0], [0]], 'TOL_214': [[0, 0, 0], [2, 3], [1]], 'TOL_145': [[3, 0, 0], [2, 0], [1]], 'TOL_90': [[3, 0, 0], [1, 2], [0]], 'TOL_26': [[1, 2, 3], [0, 0], [0]], 'TOL_154': [[3, 0, 0], [2, 0], [1]], 'TOL_176': [[3, 0, 0], [2, 0], [1]], 'TOL_75': [[3, 0, 0], [1, 2], [0]], 'TOL_112': [[2, 3, 0], [0, 0], [1]], 'TOL_3': [[1, 2, 3], [0, 0], [0]], 'TOL_19': [[1, 2, 3], [0, 0], [0]], 'TOL_92': [[3, 0, 0], [1, 2], [0]], 'TOL_16': [[1, 2, 3], [0, 0], [0]], 'TOL_117': [[2, 3, 0], [0, 0], [1]], 'TOL_55': [[2, 3, 0], [1, 0], [0]], 'TOL_177': [[3, 0, 0], [2, 0], [1]], 'TOL_196': [[0, 0, 0], [2, 3], [1]], 'TOL_123': [[2, 3, 0], [0, 0], [1]], 'TOL_205': [[0, 0, 0], [2, 3], [1]], 'TOL_206': [[0, 0, 0], [2, 3], [1]], 'TOL_30': [[1, 2, 3], [0, 0], [0]], 'TOL_86': [[3, 0, 0], [1, 2], [0]], 'TOL_1': [[1, 2, 3], [0, 0], [0]], 'TOL_58': [[2, 3, 0], [1, 0], [0]], 'TOL_5': [[1, 2, 3], [0, 0], [0]], 'TOL_175': [[3, 0, 0], [2, 0], [1]], 'TOL_180': [[0, 0, 0], [2, 3], [1]], 'TOL_102': [[3, 0, 0], [1, 2], [0]], 'TOL_53': [[2, 3, 0], [1, 0], [0]], 'TOL_109': [[2, 3, 0], [0, 0], [1]], 'TOL_9': [[1, 2, 3], [0, 0], [0]], 'TOL_21': [[1, 2, 3], [0, 0], [0]], 'TOL_2': [[1, 2, 3], [0, 0], [0]], 'TOL_193': [[0, 0, 0], [2, 3], [1]], 'TOL_7': [[1, 2, 3], [0, 0], [0]], 'TOL_127': [[2, 3, 0], [0, 0], [1]], 'TOL_108': [[2, 3, 0], [0, 0], [1]], 'TOL_160': [[3, 0, 0], [2, 0], [1]], 'TOL_89': [[3, 0, 0], [1, 2], [0]], 'TOL_147': [[3, 0, 0], [2, 0], [1]], 'TOL_137': [[2, 3, 0], [0, 0], [1]], 'TOL_143': [[2, 3, 0], [0, 0], [1]]}
var goal_boards = {'TOL_87': [[1, 0, 0], [2, 3], [0]], 'TOL_18': [[2, 3, 0], [0, 0], [1]], 'TOL_190': [[1, 2, 0], [3, 0], [0]], 'TOL_144': [[1, 2, 3], [0, 0], [0]], 'TOL_155': [[2, 1, 0], [3, 0], [0]], 'TOL_120': [[3, 0, 0], [1, 2], [0]], 'TOL_45': [[3, 1, 0], [2, 0], [0]], 'TOL_57': [[3, 1, 0], [0, 0], [2]], 'TOL_161': [[1, 0, 0], [3, 2], [0]], 'TOL_65': [[1, 0, 0], [2, 0], [3]], 'TOL_11': [[2, 1, 0], [3, 0], [0]], 'TOL_66': [[0, 0, 0], [2, 3], [1]], 'TOL_25': [[2, 0, 0], [3, 0], [1]], 'TOL_166': [[1, 2, 0], [0, 0], [3]], 'TOL_150': [[2, 3, 0], [1, 0], [0]], 'TOL_178': [[0, 0, 0], [1, 2], [3]], 'TOL_207': [[1, 0, 0], [3, 0], [2]], 'TOL_41': [[3, 2, 1], [0, 0], [0]], 'TOL_14': [[3, 0, 0], [2, 1], [0]], 'TOL_71': [[0, 0, 0], [2, 1], [3]], 'TOL_101': [[1, 0, 0], [2, 0], [3]], 'TOL_63': [[1, 0, 0], [3, 0], [2]], 'TOL_50': [[3, 0, 0], [2, 1], [0]], 'TOL_116': [[1, 3, 0], [2, 0], [0]], 'TOL_103': [[0, 0, 0], [3, 2], [1]], 'TOL_88': [[2, 0, 0], [3, 1], [0]], 'TOL_36': [[1, 2, 3], [0, 0], [0]], 'TOL_28': [[2, 0, 0], [1, 0], [3]], 'TOL_69': [[0, 0, 0], [3, 1], [2]], 'TOL_162': [[2, 3, 0], [0, 0], [1]], 'TOL_171': [[1, 0, 0], [3, 0], [2]], 'TOL_99': [[1, 0, 0], [3, 0], [2]], 'TOL_172': [[2, 0, 0], [1, 0], [3]], 'TOL_113': [[3, 2, 1], [0, 0], [0]], 'TOL_132': [[3, 0, 0], [2, 0], [1]], 'TOL_24': [[3, 0, 0], [2, 0], [1]], 'TOL_97': [[2, 0, 0], [3, 0], [1]], 'TOL_46': [[1, 2, 0], [3, 0], [0]], 'TOL_157': [[2, 0, 0], [1, 3], [0]], 'TOL_6': [[2, 3, 0], [1, 0], [0]], 'TOL_122': [[3, 0, 0], [2, 1], [0]], 'TOL_164': [[1, 3, 0], [0, 0], [2]], 'TOL_56': [[1, 3, 0], [0, 0], [2]], 'TOL_80': [[1, 3, 0], [2, 0], [0]], 'TOL_44': [[1, 3, 0], [2, 0], [0]], 'TOL_134': [[3, 0, 0], [1, 0], [2]], 'TOL_135': [[1, 0, 0], [3, 0], [2]], 'TOL_146': [[2, 1, 3], [0, 0], [0]], 'TOL_192': [[3, 0, 0], [1, 2], [0]], 'TOL_203': [[2, 1, 0], [0, 0], [3]], 'TOL_208': [[2, 0, 0], [1, 0], [3]], 'TOL_213': [[0, 0, 0], [3, 1], [2]], 'TOL_186': [[2, 3, 0], [1, 0], [0]], 'TOL_130': [[1, 2, 0], [0, 0], [3]], 'TOL_129': [[3, 1, 0], [0, 0], [2]], 'TOL_83': [[2, 1, 0], [3, 0], [0]], 'TOL_40': [[3, 1, 2], [0, 0], [0]], 'TOL_118': [[1, 2, 0], [3, 0], [0]], 'TOL_13': [[2, 0, 0], [1, 3], [0]], 'TOL_167': [[2, 1, 0], [0, 0], [3]], 'TOL_211': [[0, 0, 0], [3, 2], [1]], 'TOL_37': [[1, 3, 2], [0, 0], [0]], 'TOL_115': [[3, 2, 0], [1, 0], [0]], 'TOL_197': [[1, 0, 0], [3, 2], [0]], 'TOL_212': [[0, 0, 0], [1, 3], [2]], 'TOL_74': [[2, 1, 3], [0, 0], [0]], 'TOL_107': [[0, 0, 0], [2, 1], [3]], 'TOL_94': [[1, 2, 0], [0, 0], [3]], 'TOL_191': [[2, 1, 0], [3, 0], [0]], 'TOL_128': [[1, 3, 0], [0, 0], [2]], 'TOL_23': [[2, 1, 0], [0, 0], [3]], 'TOL_60': [[3, 0, 0], [2, 0], [1]], 'TOL_43': [[3, 2, 0], [1, 0], [0]], 'TOL_105': [[0, 0, 0], [3, 1], [2]], 'TOL_73': [[1, 3, 2], [0, 0], [0]], 'TOL_4': [[3, 1, 2], [0, 0], [0]], 'TOL_214': [[0, 0, 0], [1, 2], [3]], 'TOL_145': [[1, 3, 2], [0, 0], [0]], 'TOL_90': [[2, 3, 0], [0, 0], [1]], 'TOL_26': [[3, 0, 0], [1, 0], [2]], 'TOL_154': [[1, 2, 0], [3, 0], [0]], 'TOL_176': [[0, 0, 0], [1, 3], [2]], 'TOL_75': [[2, 3, 1], [0, 0], [0]], 'TOL_112': [[3, 1, 2], [0, 0], [0]], 'TOL_3': [[2, 3, 1], [0, 0], [0]], 'TOL_19': [[3, 2, 0], [0, 0], [1]], 'TOL_92': [[1, 3, 0], [0, 0], [2]], 'TOL_16': [[2, 0, 0], [3, 1], [0]], 'TOL_117': [[3, 1, 0], [2, 0], [0]], 'TOL_55': [[3, 2, 0], [0, 0], [1]], 'TOL_177': [[0, 0, 0], [3, 1], [2]], 'TOL_196': [[2, 0, 0], [3, 1], [0]], 'TOL_123': [[1, 0, 0], [2, 3], [0]], 'TOL_205': [[2, 0, 0], [3, 0], [1]], 'TOL_206': [[3, 0, 0], [1, 0], [2]], 'TOL_30': [[0, 0, 0], [2, 3], [1]], 'TOL_86': [[3, 0, 0], [2, 1], [0]], 'TOL_1': [[1, 3, 2], [0, 0], [0]], 'TOL_58': [[1, 2, 0], [0, 0], [3]], 'TOL_5': [[3, 2, 1], [0, 0], [0]], 'TOL_175': [[0, 0, 0], [3, 2], [1]], 'TOL_180': [[1, 2, 3], [0, 0], [0]], 'TOL_102': [[0, 0, 0], [2, 3], [1]], 'TOL_53': [[1, 0, 0], [3, 2], [0]], 'TOL_109': [[1, 3, 2], [0, 0], [0]], 'TOL_9': [[3, 1, 0], [2, 0], [0]], 'TOL_21': [[3, 1, 0], [0, 0], [2]], 'TOL_2': [[2, 1, 3], [0, 0], [0]], 'TOL_193': [[2, 0, 0], [1, 3], [0]], 'TOL_7': [[3, 2, 0], [1, 0], [0]], 'TOL_127': [[3, 2, 0], [0, 0], [1]], 'TOL_108': [[1, 2, 3], [0, 0], [0]], 'TOL_160': [[2, 0, 0], [3, 1], [0]], 'TOL_89': [[1, 0, 0], [3, 2], [0]], 'TOL_147': [[2, 3, 1], [0, 0], [0]], 'TOL_137': [[1, 0, 0], [2, 0], [3]], 'TOL_143': [[0, 0, 0], [2, 1], [3]]}
var problem_ids = ['TOL_87', 'TOL_18', 'TOL_190', 'TOL_144', 'TOL_155', 'TOL_120', 'TOL_45', 'TOL_57', 'TOL_161', 'TOL_65', 'TOL_11', 'TOL_66', 'TOL_25', 'TOL_166', 'TOL_150', 'TOL_178', 'TOL_207', 'TOL_41', 'TOL_14', 'TOL_71', 'TOL_101', 'TOL_63', 'TOL_50', 'TOL_116', 'TOL_103', 'TOL_88', 'TOL_36', 'TOL_28', 'TOL_69', 'TOL_162', 'TOL_171', 'TOL_99', 'TOL_172', 'TOL_113', 'TOL_132', 'TOL_24', 'TOL_97', 'TOL_46', 'TOL_157', 'TOL_6', 'TOL_122', 'TOL_164', 'TOL_56', 'TOL_80', 'TOL_44', 'TOL_134', 'TOL_135', 'TOL_146', 'TOL_192', 'TOL_203', 'TOL_208', 'TOL_213', 'TOL_186', 'TOL_130', 'TOL_129', 'TOL_83', 'TOL_40', 'TOL_118', 'TOL_13', 'TOL_167', 'TOL_211', 'TOL_37', 'TOL_115', 'TOL_197', 'TOL_212', 'TOL_74', 'TOL_107', 'TOL_94', 'TOL_191', 'TOL_128', 'TOL_23', 'TOL_60', 'TOL_43', 'TOL_105', 'TOL_73', 'TOL_4', 'TOL_214', 'TOL_145', 'TOL_90', 'TOL_26', 'TOL_154', 'TOL_176', 'TOL_75', 'TOL_112', 'TOL_3', 'TOL_19', 'TOL_92', 'TOL_16', 'TOL_117', 'TOL_55', 'TOL_177', 'TOL_196', 'TOL_123', 'TOL_205', 'TOL_206', 'TOL_30', 'TOL_86', 'TOL_1', 'TOL_58', 'TOL_5', 'TOL_175', 'TOL_180', 'TOL_102', 'TOL_53', 'TOL_109', 'TOL_9', 'TOL_21', 'TOL_2', 'TOL_193', 'TOL_7', 'TOL_127', 'TOL_108', 'TOL_160', 'TOL_89', 'TOL_147', 'TOL_137', 'TOL_143']
// var problems = [
//   [
//     [0, 0, 0],
//     [3, 1],
//     [2]
//   ],
//   [
//     [1, 0, 0],
//     [2, 0],
//     [3]
//   ],
//   [
//     [1, 3, 0],
//     [2, 0],
//     [0]
//   ],
//   [
//     [1, 0, 0],
//     [2, 3],
//     [0]
//   ],
//   [
//     [2, 1, 0],
//     [3, 0],
//     [0]
//   ],
//   [
//     [3, 0, 0],
//     [2, 1],
//     [0]
//   ],
//   [
//     [2, 3, 0],
//     [0, 0],
//     [1]
//   ],
//   [
//     [0, 0, 0],
//     [2, 3],
//     [1]
//   ],
//   [
//     [2, 1, 3],
//     [0, 0],
//     [0]
//   ],
//   [
//     [2, 3, 1],
//     [0, 0],
//     [0]
//   ],
//   [
//     [3, 1, 0],
//     [2, 0],
//     [0]
//   ],
//   [
//     [3, 0, 0],
//     [2, 0],
//     [1]
//   ]
// ]

var shuffled = [...problem_ids].sort(() => 0.5 - Math.random());
var problems = shuffled.slice(0, problems_total)
var answers = {'TOL_87': 5, 'TOL_18': 5, 'TOL_190': 4, 'TOL_144': 5, 'TOL_155': 7, 'TOL_120': 4, 'TOL_45': 5, 'TOL_57': 4, 'TOL_161': 6, 'TOL_65': 7, 'TOL_11': 5, 'TOL_66': 7, 'TOL_25': 4, 'TOL_166': 4, 'TOL_150': 6, 'TOL_178': 4, 'TOL_207': 4, 'TOL_41': 5, 'TOL_14': 4, 'TOL_71': 7, 'TOL_101': 6, 'TOL_63': 5, 'TOL_50': 6, 'TOL_116': 6, 'TOL_103': 6, 'TOL_88': 5, 'TOL_36': 6, 'TOL_28': 7, 'TOL_69': 4, 'TOL_162': 7, 'TOL_171': 5, 'TOL_99': 7, 'TOL_172': 5, 'TOL_113': 6, 'TOL_132': 7, 'TOL_24': 5, 'TOL_97': 5, 'TOL_46': 5, 'TOL_157': 5, 'TOL_6': 6, 'TOL_122': 7, 'TOL_164': 4, 'TOL_56': 6, 'TOL_80': 6, 'TOL_44': 7, 'TOL_134': 4, 'TOL_135': 4, 'TOL_146': 7, 'TOL_192': 4, 'TOL_203': 7, 'TOL_208': 6, 'TOL_213': 5, 'TOL_186': 7, 'TOL_130': 5, 'TOL_129': 5, 'TOL_83': 4, 'TOL_40': 5, 'TOL_118': 4, 'TOL_13': 7, 'TOL_167': 6, 'TOL_211': 6, 'TOL_37': 7, 'TOL_115': 5, 'TOL_197': 5, 'TOL_212': 5, 'TOL_74': 4, 'TOL_107': 5, 'TOL_94': 7, 'TOL_191': 7, 'TOL_128': 5, 'TOL_23': 6, 'TOL_60': 6, 'TOL_43': 4, 'TOL_105': 6, 'TOL_73': 7, 'TOL_4': 6, 'TOL_214': 5, 'TOL_145': 4, 'TOL_90': 4, 'TOL_26': 7, 'TOL_154': 5, 'TOL_176': 4, 'TOL_75': 4, 'TOL_112': 6, 'TOL_3': 6, 'TOL_19': 6, 'TOL_92': 7, 'TOL_16': 4, 'TOL_117': 6, 'TOL_55': 5, 'TOL_177': 6, 'TOL_196': 6, 'TOL_123': 7, 'TOL_205': 7, 'TOL_206': 4, 'TOL_30': 4, 'TOL_86': 4, 'TOL_1': 4, 'TOL_58': 6, 'TOL_5': 7, 'TOL_175': 7, 'TOL_180': 4, 'TOL_102': 4, 'TOL_53': 4, 'TOL_109': 6, 'TOL_9': 5, 'TOL_21': 6, 'TOL_2': 6, 'TOL_193': 6, 'TOL_7': 7, 'TOL_127': 6, 'TOL_108': 5, 'TOL_160': 7, 'TOL_89': 7, 'TOL_147': 7, 'TOL_137': 6, 'TOL_143': 7}

// var answers = [2, 2, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5]
var held_ball = 0

/* ************************************ */
/* Set up jsPsych blocks */
/* ************************************ */
//Set up post task questionnaire
var post_task_block = {
   type: 'survey-text',
   data: {
       trial_id: "post task questions"
   },
   questions: ['<p class = center-block-text style = "font-size: 20px">Please summarize what you were asked to do in this task.</p>',
              '<p class = center-block-text style = "font-size: 20px">Do you have any comments about this task?</p>'],
   rows: [15, 15],
   columns: [60,60]
};

/* define static blocks */
var end_block = {
  type: 'poldrack-text',
  data: {
    trial_id: "end",
    exp_id: 'tower_of_london'
  },
  text: '<div class = centerbox><p class = center-block-text>Thanks for completing this task!</p><p class = center-block-text>Press <strong>enter</strong> to continue.</p></div>',
  cont_key: [13],
  timing_post_trial: 0,
  on_finish: assessPerformance
};

var feedback_instruct_text =
  'Welcome to the experiment. This experiment will take about 20 minutes. Press <strong>enter</strong> to begin.'
var feedback_instruct_block = {
  type: 'poldrack-text',
  data: {
    trial_id: "instruction"
  },
  cont_key: [13],
  text: getInstructFeedback,
  timing_post_trial: 0
};
/// This ensures that the subject does not read through the instructions too quickly.  If they do it too quickly, then we will go over the loop again.
var instructions_block = {
  type: 'poldrack-instructions',
  data: {
    trial_id: "instruction"
  },
  pages: [
    '<div class = tol_topbox><p class = block-text>During this task, two boards will be presented at a time. The boards will show colored balls arranged on pegs like this:</p></div>' +
    ref_board + makeBoard('peg_board', example_problem1) +
    '<div class = tol_bottombox><p class = block-text>Imagine that these balls have holes through them and that the pegs go through the holes. Notice that the first peg can hold three balls, the second peg can hold two balls, and the third peg can hold one ball.</p></div>',
    '<div class = tol_topbox><p class = block-text>Your task will be to make your board look like the target board.</p></div>' +
    ref_board + makeBoard('peg_board', example_problem1) +
    '<div class = tol_bottombox><p class = block-text>The balls in the target board are fixed in place, but the balls in your board are movable. You have to move them to make your board look like the target board. Sometime you will have to move a ball to a different peg in order to get to the ball below it.</p></div>',
    '<div class = tol_topbox><p class = block-text>Here is an example. Notice that your board looks different from the target board. If we move the red ball from the first peg in your board to the third peg then it would look like the target board.</p></div>' +
    ref_board + makeBoard('peg_board', example_problem2) + '<div class = tol_bottombox></div>',
    "<div class = centerbox><p class = block-text>During the test you will move the balls on your board by clicking on the pegs. When you click on a peg, the top ball will move into a box called 'your hand'. When you click on another peg, the ball in 'your hand' will move to the top of that peg.</p><p class = block-text>If you try to select a peg with no balls or try to place a ball on a full peg, nothing will happen. If you successfully make your board look like the target board, the trial will end and you will move to the next problem.</p><p class = block-text>We will start with an easy example so that you can learn the controls.</p></div>"
  ],
  allow_keys: false,
  show_clickable_nav: true,
  timing_post_trial: 1000
};

var instructions_block_full = {
  type: 'poldrack-instructions',
  data: {
    trial_id: "instruction"
  },
  pages: [
    '<div class = tol_topbox><p class = block-text>During this task, two boards will be presented at a time. The boards will show colored balls arranged on pegs like this:</p></div>' +
    ref_board + makeBoard('peg_board', example_problem1) +
    '<div class = tol_bottombox><p class = block-text>Imagine that these balls have holes through them and that the pegs go through the holes. Notice that the first peg can hold three balls, the second peg can hold two balls, and the third peg can hold one ball.</p></div>',
    '<div class = tol_topbox><p class = block-text>Your task will be to make your board look like the target board in the fewest possible moves.</p></div>' +
    ref_board + makeBoard('peg_board', example_problem1) +
    '<div class = tol_bottombox><p class = block-text>The balls in the target board are fixed in place, but the balls in your board are movable. You have to move them to make your board look like the target board. Sometimes you will have to move a ball to a different peg in order to get to the ball below it. During this task it is important to aim for the <strong>fewest possible moves</strong> that are required to make your board look like the target board.</p></div>',
    '<div class = tol_topbox><p class = block-text>Here is an example. Notice that your board looks different from the target board. If we move the red ball from the first peg in your board to the third peg then it would look like the target board.</p></div>' +
    ref_board + makeBoard('peg_board', example_problem2) + '<div class = tol_bottombox></div>',
    "<div class = centerbox><p class = block-text>During the test you will move the balls on your board by clicking on the pegs. When you click on a peg, the top ball will move into a box called 'your hand'. When you click on another peg, the ball in 'your hand' will move to the top of that peg.</p><p class = block-text>If you try to select a peg with no balls or try to place a ball on a full peg, nothing will happen. If you successfully make your board look like the target board, the trial will end and you will move to the next problem. <strong>Before moving any of the balls, please figure out a complete set of moves in your head that will make your board look like the target board. You can then go ahead and carry out these moves.</strong></p><p class = block-text>We will start with an easy example so that you can learn the controls.</p></div>"
  ],
  allow_keys: false,
  show_clickable_nav: true,
  timing_post_trial: 1000
};


var instructioncorrect = false;
var instruction_check = {
    type: "survey-multi-choice",
    required: [true, true, true],
    preamble: ["<p align='center'><b>Check your knowledge before you begin!</b></p>"],
    questions: [
      "<b>Question 1</b>: The peg on the far left of the board can hold up to ",
      "<b>Question 2</b>: Your goal is to",
      "<b>Question 3</b>: You can move balls by "
    ],
    options: [[" 1 ball", " 2 balls", " 3 balls"],[" make your board look like the target board", " move the balls in your board to one peg"], [" clicking with the mouse", " dragging with the mouse", " using the keyboard"]],
    on_finish: function(data) {
      if( data.responses == '{"Q0":" 3 balls","Q1":" make your board look like the target board","Q2":" clicking with the mouse"}') {
        action = false;
        instructioncorrect = true;
      }
    }
}

var instruction_check_full = {
    type: "survey-multi-choice",
    required: [true, true, true, true],
    preamble: ["<p align='center'><b>Check your knowledge before you begin!</b></p>"],
    questions: [
      "<b>Question 1</b>: The peg on the far left of the board can hold up to ",
      "<b>Question 2</b>: Your goal is to",
      "<b>Question 3</b>: You can move balls by ",
      "<b>Question 4</b>: Which is correct? "
    ],
    options: [[" 1 ball", " 2 balls", " 3 balls"],[" make your board look like the target board", " make your board look like the target board in the fewest possible moves", " move the balls in your board to one peg"], [" clicking with the mouse", " dragging with the mouse", " using the keyboard"], [" You can start moving balls before you know for sure how to make your board look like the target", " Before moving any balls, you should figure out a complete set of moves in your head that will make your board look like the target"]],
    on_finish: function(data) {
      if( data.responses == '{"Q0":" 3 balls","Q1":" make your board look like the target board in the fewest possible moves","Q2":" clicking with the mouse","Q3":" Before moving any balls, you should figure out a complete set of moves in your head that will make your board look like the target"}') {
        action = false;
        instructioncorrect = true;
      }
    }
}






var start_test_block = {
  type: 'poldrack-text',
  data: {
    trial_id: "instruction"
  },
  text: '<div class = centerbox><p class = block-text>Well done! We will now start Problem 1. There will be ' +
    problems_total + ' problems to complete. Press <strong>enter</strong> to begin. </p></div>',
  cont_key: [13],
  timing_post_trial: 1000,
  on_finish: function() {
    exp_stage = 'test'
    held_ball = 0
    time_elapsed = 0
    num_moves = 0
    curr_placement = init_boards[problems[problem_i]];
  }
};

var start_test_block_full = {
  type: 'poldrack-text',
  data: {
    trial_id: "instruction"
  },
  text: '<div class = centerbox><p class = block-text>Well done! We will now start Problem 1. There will be ' +
    problems_total + ' problems to complete. <strong>Before moving any of the balls, remember figure out a complete set of moves in your head that will make your board look like the target board.</strong> Press <strong>enter</strong> to begin. </p></div>',
  cont_key: [13],
  timing_post_trial: 1000,
  on_finish: function() {
    exp_stage = 'test'
    held_ball = 0
    time_elapsed = 0
    num_moves = 0
    curr_placement = init_boards[problems[problem_i]];
  }
};

var start_practice_block_full = {
  type: 'poldrack-text',
  data: {
    trial_id: "practice",
    exp_stage: 'test'
  },
  text: '<div class = centerbox><p class = center-block-text> Press <strong>enter</strong> to begin the practice trial. <strong>Before moving any of the balls, please figure out a complete set of moves in your head that will make your board look like the target board. You can then go ahead and carry out these moves.</strong></p></div>',
  cont_key: [13],
}

var start_practice_block = {
  type: 'poldrack-text',
  data: {
    trial_id: "practice",
    exp_stage: 'test'
  },
  text: '<div class = centerbox><p class = center-block-text> Press <strong>enter</strong> to begin the practice trial.</p></div>',
  cont_key: [13],
}

var advance_problem_block = {
  type: 'poldrack-text',
  data: {
    trial_id: "advance",
    exp_stage: 'test'
  },
  text: getText,
  cont_key: [13],
  on_finish: function() {
    held_ball = 0
    time_elapsed = 0
    problem_i += 1;
    num_moves = 0;
    curr_placement = init_boards[problems[problem_i]]
  }
}

var advance_problem_block_full = {
  type: 'poldrack-text',
  data: {
    trial_id: "advance",
    exp_stage: 'test'
  },
  text: getText_full,
  cont_key: [13],
  on_finish: function() {
    held_ball = 0
    time_elapsed = 0
    problem_i += 1;
    num_moves = 0;
    curr_placement = init_boards[problems[problem_i]]
  }
}


var practice_tohand = {
  type: 'single-stim-button',
  stimulus: getPractice,
  button_class: 'special',
  is_html: true,
  data: {
    trial_id: "to_hand",
    exp_stage: 'practice'
  },
  timing_post_trial: 0,
  on_finish: function(data) {
    if (data.mouse_click != -1) {
      time_elapsed += data.rt
    } else {
      time_elapsed += getTime()
    }
    jsPsych.data.addDataToLastTrial({
      'current_position': jQuery.extend(true, [], curr_placement),
      'num_moves_made': num_moves,
      'target': example_problem3,
      'min_moves': 2,
      'problem_id': 'practice'
    })
  }
}

var practice_toboard = {
  type: 'single-stim-button',
  stimulus: getPractice,
  button_class: 'special',
  is_html: true,
  data: {
    trial_id: "to_board",
    exp_stage: 'practice'
  },
  timing_post_trial: 0,
  on_finish: function(data) {
    if (data.mouse_click != -1) {
      time_elapsed += data.rt
    } else {
      time_elapsed += getTime()
    }
    jsPsych.data.addDataToLastTrial({
      'current_position': jQuery.extend(true, [], curr_placement),
      'num_moves_made': num_moves,
      'target': example_problem3,
      'min_moves': 2,
      'problem_id': 'practice'
    })
  }
}

var test_tohand = {
  type: 'single-stim-button',
  stimulus: getStim,
  button_class: 'special',
  is_html: true,
  data: {
    trial_id: "to_hand",
    exp_stage: 'test'
  },
  timing_post_trial: 0,
  on_finish: function(data) {
    if (data.mouse_click != -1) {
      time_elapsed += data.rt
    } else {
      time_elapsed += getTime()
    }
    jsPsych.data.addDataToLastTrial({
      'current_position': jQuery.extend(true, [], curr_placement),
      'num_moves_made': num_moves,
      'target': goal_boards[problems[problem_i]],
      'min_moves': answers[problems[problem_i]],
      'problem_id': problems[problem_i]
    })
  }
}

var test_toboard = {
  type: 'single-stim-button',
  stimulus: getStim,
  button_class: 'special',
  is_html: true,
  data: {
    trial_id: "to_board",
    exp_stage: 'test'
  },
  timing_post_trial: 0,
  on_finish: function(data) {
    if (data.mouse_click != -1) {
      time_elapsed += data.rt
    } else {
      time_elapsed += getTime()
    }
    jsPsych.data.addDataToLastTrial({
      'current_position': jQuery.extend(true, [], curr_placement),
      'num_moves_made': num_moves,
      'target': goal_boards[problems[problem_i]],
      'min_moves': answers[problems[problem_i]],
      'problem_id': problems[problem_i]
    })
  }
}

var feedback_block = {
  type: 'poldrack-single-stim',
  stimulus: getFB,
  choices: 'none',
  is_html: true,
  data: {
    trial_id: 'feedback'
  },
  timing_stim: 2000,
  timing_response: 2000,
  timing_post_trial: 500,
  on_finish: function() {
    jsPsych.data.addDataToLastTrial({
      'exp_stage': exp_stage,
      'problem_time': time_elapsed,
      'correct': correct
    })
  },
}

var feedback_blockfull = {
  type: 'poldrack-single-stim',
  stimulus: getFBfull,
  choices: 'none',
  is_html: true,
  data: {
    trial_id: 'feedback'
  },
  timing_stim: 2000,
  timing_response: 2000,
  timing_post_trial: 500,
  on_finish: function() {
    jsPsych.data.addDataToLastTrial({
      'exp_stage': exp_stage,
      'problem_time': time_elapsed,
      'correct': correct
    })
  },
}

var practice_node = {
  timeline: [practice_tohand, practice_toboard],
  loop_function: function(data) {
    // if (time_elapsed >= time_per_trial) {
    //   return false
    // }
    data = data[1]
    var target = data.target
    var isequal = true
    for (var i = 0; i < target.length; i++) {
      isequal = arraysEqual(target[i], data.current_position[i])
      if (isequal === false) {
        break;
      }
    }
    return !isequal
  },
  timing_post_trial: 1000
}

var problem_node = {
  timeline: [test_tohand, test_toboard],
  loop_function: function(data) {
    // if (time_elapsed >= time_per_trial) {
    //   return false
    // }
    data = data[1]
    var target = data.target
    var isequal = true
    for (var i = 0; i < target.length; i++) {
      isequal = arraysEqual(target[i], data.current_position[i])
      if (isequal === false) {
        break;
      }
    }
    return !isequal
  },
  timing_post_trial: 1000
}


var instruction_node = {
  timeline: [feedback_instruct_block, instructions_block, start_practice_block, practice_node, feedback_block, instruction_check],
  /* This function defines stopping criteria */
  loop_function: function(data) {
    // for (i = 0; i < data.length; i++) {
    //   if ((data[i].trial_type == 'poldrack-instructions') && (data[i].rt != -1)) {
    //     rt = data[i].rt
    //     sumInstructTime = sumInstructTime + rt
    //   }
    // }
    //
    //
    //
    // if (sumInstructTime <= instructTimeThresh * 1000) {
    //   feedback_instruct_text =
    //     'Read through instructions too quickly.  Please take your time and make sure you understand the instructions.  Press <strong>enter</strong> to continue.'
    //   return true
    // } else if (sumInstructTime > instructTimeThresh * 1000) {
    //   feedback_instruct_text =
    //     'Done with instructions. Press <strong>enter</strong> to continue.'
    //   return false
    if (instructioncorrect) {
      feedback_instruct_text =
          'Done with instructions. Press <strong>enter</strong> to continue.'
      return false
    }
    else {
        feedback_instruct_text =
          'Unfortunately, at least one of your answers was incorrect. Press <strong>enter</strong> to continue.'

        curr_placement = [
          [1, 2, 0],
          [3, 0],
          [0]
        ]

        num_moves = 0

        return true
    }


  }
}

var instruction_node_full = {
  timeline: [feedback_instruct_block, instructions_block_full, start_practice_block_full, practice_node, feedback_blockfull, instruction_check_full],
  /* This function defines stopping criteria */
  loop_function: function(data) {
    // for (i = 0; i < data.length; i++) {
    //   if ((data[i].trial_type == 'poldrack-instructions') && (data[i].rt != -1)) {
    //     rt = data[i].rt
    //     sumInstructTime = sumInstructTime + rt
    //   }
    // }
    // if (sumInstructTime <= instructTimeThresh * 1000) {
    //   feedback_instruct_text =
    //     'Read through instructions too quickly.  Please take your time and make sure you understand the instructions.  Press <strong>enter</strong> to continue.'
    //   return true
    // } else if (sumInstructTime > instructTimeThresh * 1000) {
    //   feedback_instruct_text =
    //     'Done with instructions. Press <strong>enter</strong> to continue.'
    //   return false
    if (instructioncorrect) {
      feedback_instruct_text =
          'Done with instructions. Press <strong>enter</strong> to continue.'
      return false
    }
    else {
        feedback_instruct_text =
          'Unfortunately, at least one of your answers was incorrect. Press <strong>enter</strong> to continue.'

        curr_placement = [
          [1, 2, 0],
          [3, 0],
          [0]
        ]

        num_moves = 0

        return true
    }

  }
}


/* create experiment definition array */
var tower_of_london_experiment = [];
tower_of_london_experiment.push(instruction_node);
tower_of_london_experiment.push(start_test_block);
for (var i = 0; i < problems_total; i++) {
  tower_of_london_experiment.push(problem_node);
  tower_of_london_experiment.push(feedback_block)
  if (i != problems_total-1) {
    tower_of_london_experiment.push(advance_problem_block)
  }

}
tower_of_london_experiment.push(post_task_block)
tower_of_london_experiment.push(end_block);


var tower_of_london_experiment_full = [];
tower_of_london_experiment_full.push(instruction_node_full);
tower_of_london_experiment_full.push(start_test_block_full);
for (var i = 0; i < problems_total; i++) {
  tower_of_london_experiment_full.push(problem_node);
  tower_of_london_experiment_full.push(feedback_blockfull)
  if (i != problems_total-1) {
    tower_of_london_experiment_full.push(advance_problem_block_full)
  }

}
tower_of_london_experiment_full.push(post_task_block)
tower_of_london_experiment_full.push(end_block);
