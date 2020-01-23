class Move
  VALID_VALUES = ["rock", "paper", "scissors"]
  def initialize(value=nil)
    @value = value || VALID_VALUES.sample
  end

  def to_s
    @value.to_s
  end
end

class Player
  attr_reader :move, :name

  def initialize
    @move = nil
    @name = nil
  end

  def to_s
    "#{name} chose #{move}"
  end

  def rock?
    move.to_s == "rock"
  end

  def paper?
    move.to_s == "paper"
  end

  def scissors?
    move.to_s == "scissors"
  end

  def <=>(other_player)
    if first_win?(self, other_player)
      -1
    elsif first_win?(other_player, self)
      1
    else
      0
    end
  end

  def first_win?(first, second)
    (first.rock? && second.scissors?) ||
      (first.paper? && second.rock?) ||
      (first.scissors? && second.paper?)
  end
end

class Human < Player
  def choose
    puts "What do you choose? rock - paper - scissors?"
    choice = nil
    loop do
      choice = gets.chomp.downcase
      break if Move::VALID_VALUES.include?(choice)
      puts "Sorry, it is not a valid choice"
    end
    @move = Move.new(choice)
  end

  def set_name
    puts "What is your name?"
    name = nil
    loop do
      name = gets.chomp
      break unless name.empty?
      puts "Please enter something."
    end
    @name = name
  end
end

class Computer < Player
  def choose
    @move = Move.new
  end

  def set_name
    @name = "Hal"
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to rock-paper-scissors game."
  end

  def display_winner
    puts human
    puts computer
    case human <=> computer
    when -1 then puts "#{human.name} won"
    when 0 then puts "It's a tie"
    when 1 then puts "#{computer.name} won"
    end
  end

  def display_goodbye_message
    puts "Thank your for playing with me."
  end

  def play_again?
    loop do
      puts "Do you want to play again? y/n"
      choice = gets.chomp.downcase
      return false if choice == "n"
      return 1 if choice == "y"
      puts "It's not a valid choice"
    end
  end

  def play
    display_welcome_message
    human.set_name
    computer.set_name
    loop do
      human.choose
      computer.choose
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
