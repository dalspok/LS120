class Player
  attr_accessor :choice, :name

  def to_s
    @name
  end
end

class Human < Player
  def move
    choice = nil
    loop do
      puts "What is your choice (#{Move::VALUES.join(', ')})?"
      choice = gets.chomp
      break if Move::VALUES.include? choice.downcase
      puts "Sorry, that is incorrect choice."
      puts
    end
    self.choice = Move.new(choice)
  end
end

class Computer < Player
  NAMES_VALUES = ["Atari", "Hal", "Sinclair"]

  def initialize
    @name = NAMES_VALUES.sample
  end

  def move
    self.choice = Move.new(Move::VALUES.sample)
  end
end

class Move
  VALUES = ["rock", "paper", "scissors"]

  attr_accessor :value
  def initialize(value)
    self.value = value
  end

  def >(other_choice)
    value == "rock" && other_choice.value == "scissors" ||
      value == "paper" && other_choice.value == "rock" ||
      value == "scissors" && other_choice.value == "paper"
  end

  def <(other_choice)
    value == "rock" && other_choice.value == "paper" ||
      value == "paper" && other_choice.value == "scissors" ||
      value == "scissors" && other_choice.value == "rock"
  end

  def to_s
    @value
  end
end

class RPSGame
  attr_accessor :player, :computer

  def initialize
    self.player = Human.new
    self.computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome!"
  end

  def display_goodbye_message
    puts "Thank you for playing."
  end

  def determine_winner
    if player.choice > computer.choice
      puts "#{player} won!"
    elsif player.choice < computer.choice
      puts "#{computer} won!"
    else
      puts "It's a tie"
    end
  end

  def display_choices
    puts "#{player} chose #{player.choice}"
    puts "#{computer} chose #{computer.choice}"
  end

  def continue?
    choice = nil
    loop do
      puts "Do you want to continue? (y/n)"
      choice = gets.chomp.downcase
      break if %w[y n].include? choice
      puts "Sorry, not a valid choice"
    end
    choice == "y"
  end

  def obtain_player_name
    choice = nil
    loop do
      puts "What is your name?"
      choice = gets.chomp
      break unless choice.empty?
      puts "Sorry, not a valid choice"
    end
    player.name = choice
  end

  def play
    display_welcome_message
    obtain_player_name
    loop do
      player.move
      computer.move
      display_choices
      determine_winner
      break unless continue?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
