
class Move
  VALUES = { "r" => "rock",
             "p" => "paper",
             "s" => "scissors",
             "l" => "lizard",
             "o" => "Spock" }

  WINNING_MOVES = { "rock" => ["scissors", "lizard"],
                    "paper" => ["rock", "Spock"],
                    "scissors" => ["paper", "lizard"],
                    "lizard" => ["paper", "Spock"],
                    "Spock" => ["scissors", "rock"] }

  attr_accessor :value

  def initialize(choice)
    @value = choice
  end

  def <(other_move)
    WINNING_MOVES[other_move.value].include? value
  end

  def >(other_move)
    WINNING_MOVES[value].include? other_move.value
  end

  def to_s
    value
  end
end

class Player
  attr_accessor :move, :score

  def initialize
    @score = 0
  end
end

class Human < Player
  def choose
    choice = nil
    puts "What's your choice?"
    puts "Choose from (R)ock-(P)aper-(S)cissors-(L)izard-Sp(O)ck"
    loop do
      choice = gets.chomp.downcase
      break if Move::VALUES.keys.include? choice
      puts "Sorry, it's not a correct choice. Please try again."
    end

    self.move = Move.new(Move::VALUES[choice])
    system "clear"
  end
end

class Computer < Player
  def choose
    self.move = Move.new(Move::VALUES.values.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer
  FINAL_SCORE = 5

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    system "clear"
    puts "Welcome to the game."
    puts "Press Enter to start"
    gets
    system "clear"
  end

  def display_scores
    puts "You: #{human.score} | Computer: #{computer.score}"
  end

  def increment_scores
    case determine_winner
    when :human then human.score += 1
    when :computer then computer.score += 1
    end
  end

  def determine_winner
    if human.move > computer.move
      :human
    elsif computer.move > human.move
      :computer
    else
      :tie
    end
  end

  def display_players
    puts "You chose #{human.move}"
    puts "Computer chose #{computer.move}"
  end

  def display_winner
    case determine_winner
    when :human then puts "You won"
    when :computer then puts "Computer won"
    else puts "It's a tie"
    end
  end

  def final_winner
    if human.score == FINAL_SCORE then "player"
    elsif computer.score == FINAL_SCORE then "computer"
    end
  end

  def display_goodbye_message
    puts "Final winner is: #{final_winner}. Thank you for playing"
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      increment_scores
      display_players
      display_winner
      display_scores
      break if final_winner
    end
    display_goodbye_message
  end
end

RPSGame.new.play
