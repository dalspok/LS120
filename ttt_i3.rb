class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]
  NUM_OF_ROWS = 3
  attr_reader :squares

  def initialize
    @squares = {}
    reset
  end

  def reset
    (1..9).each { |index| @squares[index] = Square.new }
  end

  def display
    system "clear"
    puts
    puts "     |     |     "
    puts "  #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}  "
    puts "     |     |     "
    puts "-----|-----|-----"
    puts "     |     |     "
    puts "  #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}  "
    puts "     |     |     "
    puts "-----|-----|-----"
    puts "     |     |     "
    puts "  #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}  "
    puts "     |     |     "
    puts
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def empty_keys
    squares.select { |_, square| square.marker == TTTGame::EMPTY_MARKER }.keys
  end

  def full?
    empty_keys.empty?
  end

  def winning_marker
    WINNING_LINES.each do |line|
      [TTTGame::HUMAN_MARKER, TTTGame::COMPUTER_MARKER].each do |marker|
        if squares.values_at(*line).map(&:marker).count(marker) == NUM_OF_ROWS
          return marker
        end
      end
    end
  end
end

class Square
  attr_accessor :marker

  def initialize(marker=TTTGame::EMPTY_MARKER)
    @marker = marker
  end

  def to_s
    marker
  end
end

class Player
  attr_reader :marker
  def initialize(marker)
    @marker = marker
  end
end

class TTTGame
  EMPTY_MARKER = " "
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
  end

  def display_welcome_message
    puts "Welcome to tic-tac-toe"
  end

  def human_moves
    puts "Choose a square from #{board.empty_keys.join(', ')}"
    choice = ""
    loop do
      choice = gets.chomp.to_i
      break if board.empty_keys.include? choice
      puts "Sorry, that's an incorrect choice. Try again."
    end

    board[choice] = human.marker
  end

  def computer_moves
    choice = board.empty_keys.sample
    board[choice] = computer.marker
  end

  def someone_won?
    !!winner
  end

  def winner
    if board.winning_marker == HUMAN_MARKER
      "You"
    elsif board.winning_marker == COMPUTER_MARKER
      "Computer"
    end
  end

  def display_result
    if someone_won?
      puts "#{winner} won the game!"
    else
      puts "It's a tie."
    end
  end

  def play_again?
    choice = nil
    loop do
      puts "Do you want to play again? (y/n)"
      choice = gets.chomp.downcase
      break if %w[y n].include? choice
      puts "Sorry, that's not a correct choice."
    end
    choice == "y"
  end

  def display_goodbye_message
    puts "Thank you for playing."
  end

  def play
    display_welcome_message
    loop do
      board.reset
      loop do
        board.display
        human_moves
        break if someone_won? || board.full?

        computer_moves
        break if someone_won? || board.full?
      end
      board.display
      display_result
      break unless play_again?
    end
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
