system("clr") || system("clear")

class Player
  attr_reader :player_type
  attr_accessor :choice, :name, :score

  def initialize
    @score = 0
  end

  def upgrade_score
    self.score += 1
  end

  def reset_score
    self.score = 0
  end
end

class Human < Player
  def initialize
    super
    set_name
  end

  def set_name
    n = nil
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.strip.empty?
      puts "Invalid input, please try again:"
    end
    self.name = n
  end

  def choose
    player_choice = obtain_input
    self.choice = if player_choice == "spock"
                    Move.new(player_choice.capitalize)
                  elsif Move::ACCEPTED_INPUT_WORDS.include? player_choice
                    Move.new(player_choice)
                  else
                    Move.new(Move::CHOICES[player_choice])
                  end
    system("clr") || system("clear")
  end

  def obtain_input
    loop do
      puts
      puts "What's your choice? (r)ock - (p)aper" \
      " - (s)cissors - (l)izard - Sp(o)ck"
      player_choice = gets.chomp.downcase
      return player_choice if Move::ACCEPTED_INPUTS.include? player_choice
      puts "Wrong choice, pleas try again."
    end
  end
end

class Computer < Player
  attr_accessor :weights, :history, :initial_weights

  def initialize
    super
    @history = History.new
  end

  def reset_weights
    @weights = @initial_weights.dup
  end

  def analyze_frequencies(whom)
    # returns hash of freqencies in percents {"rock" => 30 ...}
    moves_history = history.print.map { |lap| lap[whom] }
    possible_moves = Move::CHOICES.values
    frequencies = {}
    possible_moves.map do |move|
      if moves_history.empty?
        frequency_count = 0
      else
        frequency_ratio = (moves_history.count(move) / moves_history.size.to_f)
        frequency_count = frequency_ratio * 100
      end
      frequencies[move] = frequency_count
    end
    frequencies
  end

  def weighted_choices
    weights.map { |move, weight| [move] * weight }.flatten
  end

  def choose
    adapt_weights_to_behavior
    self.choice = Move.new(weighted_choices.sample)
  end
end

class SmartComputer < Computer
  MOVES_THRESHOLD_PERCENT = 30
  attr_accessor :adaptive

  def initialize(adaptive=10)
    # 10-absolutely/0-not at all - how adaptive to freq of human moves
    super()
    set_default_initial_weights
    reset_weights
    @adaptive = adaptive
  end

  def set_default_initial_weights
    choices = Move::CHOICES.values
    @initial_weights = {}
    choices.each_with_index { |choice| @initial_weights[choice] = 10 }
  end

  def adapt_weights_to_behavior
    possible_moves = Move::CHOICES.values
    frequencies = analyze_frequencies(:human)
    reset_weights
    possible_moves.each do |move|
      if frequencies[move] > MOVES_THRESHOLD_PERCENT
        @weights[Move::WINNING_HANDS[move][0]] = (10 - adaptive)
        @weights[Move::WINNING_HANDS[move][1]] = (10 - adaptive)
      end
    end
  end
end

class StubbornComputer < Computer
  def initialize(initial_weights)
    super()
    @initial_weights = initial_weights
    reset_weights
  end

  def adapt_weights_to_behavior
    true
  end
end

class History
  def initialize
    @history = []
  end

  def save(human_choice, computer_choice, winner)
    @history << { human: human_choice,
                  computer: computer_choice,
                  winner: winner }
  end

  def print
    @history
  end
end

class Move
  attr_accessor :value
  CHOICES = { "r" => "rock", "p" => "paper", "s" => "scissors",
              "l" => "lizard", "o" => "Spock" }
  WINNING_HANDS = { "rock" => ["lizard", "scissors"],
                    "lizard" => ["Spock", "paper"],
                    "Spock" => ["scissors", "rock"],
                    "scissors" => ["paper", "lizard"],
                    "paper" => ["rock", "Spock"] }
  ACCEPTED_INPUT_WORDS = Move::CHOICES.values.map(&:downcase)
  ACCEPTED_INPUTS = Move::CHOICES.keys + ACCEPTED_INPUT_WORDS

  def initialize(value)
    @value = value
  end

  def >(other_move)
    WINNING_HANDS[value].include? other_move.value
  end

  def <(other_move)
    WINNING_HANDS[other_move.value].include? value
  end

  def to_s
    @value
  end
end

class RPSGame
  attr_accessor :human, :computer
  FINAL_SCORE = 5

  def initialize
    display_welcome_message
    @human = Human.new
  end

  def display_moves
    puts
    puts "#{human.name} chose #{human.choice}"
    puts "#{computer.name} chose #{computer.choice}"
  end

  def choose_computer_personality
    choice = [:stubborn, :smart].sample
    if choice == :stubborn
      name, strategy = [["Atari",
                         { "rock" => 10, "paper" => 10, "scissors" => 10,
                           "lizard" => 0, "Spock" => 0 }],
                        ["Spock",
                         { "rock" => 1, "paper" => 2, "scissors" => 2,
                           "lizard" => 2, "Spock" => 10 }]].sample

      @computer = StubbornComputer.new(strategy)
    else
      name, strategy = [["HAL", 10], ["ZX spectrum", 0]].sample
      @computer = SmartComputer.new(strategy)
    end
    computer.name = name
  end

  def display_winner(winner)
    if winner
      puts "#{winner.name} wins"
    else
      puts "It's a tie"
    end
  end

  def save_history(winner)
    winner_type = winner ? winner.class.to_s.downcase : "tie"
    human_choice = human.choice.value
    computer_choice = computer.choice.value
    computer.history.save(human_choice, computer_choice, winner_type)
  end

  def determine_winner
    # rubocop:  disable Style/EmptyElse
    if human.choice > computer.choice
      human
    elsif human.choice < computer.choice
      computer
    else
      nil # nil explicitly left here: nil = tie
    end
    # rubocop:  enable Style/EmptyElse
  end

  def display_score
    puts "#{human.name}:#{computer.name} - #{human.score}:#{computer.score}"
  end

  def display_welcome_message
    puts "Welcome to Rock Paper Scissors game."
    puts "We will play till #{RPSGame::FINAL_SCORE} winning rounds."
  end

  def display_computer_name
    puts "Your competitor is #{computer.name}"
  end

  def display_goodbye_message
    puts "Thank you for playing"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ["y", "n", "yes", "no"].include? answer
      puts "Sorry, not a valid choice"
    end
    system("clr") || system("clear")
    ["y", "yes"].include? answer
  end

  def final_winner
    human.score == RPSGame::FINAL_SCORE ? human : computer
  end

  def display_final_result
    puts "Total winner is #{final_winner.name}. Game over."
  end

  def final_score_reached?
    final = RPSGame::FINAL_SCORE
    human.score == final || computer.score == final
  end

  def play
    loop do
      choose_computer_personality
      display_computer_name
      computer.reset_score
      human.reset_score
      play_rounds
      display_final_result
      break unless play_again?
    end
    display_goodbye_message
  end

  def play_rounds
    loop do
      human.choose
      computer.choose
      display_moves
      winner = determine_winner
      display_winner(winner)
      winner&.upgrade_score
      display_score
      save_history(winner)

      break if final_score_reached?
    end
  end
end

RPSGame.new.play
