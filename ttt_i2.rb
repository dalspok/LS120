class Board
  attr_reader :squares
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
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

  def assign(mark, square)
    squares[square].mark = mark
  end

  def empty_squares
    squares.select { |_, square| square.empty? }
           .keys
  end

  def winner
    if full_winning_line?(TTTGame::PLAYER_MARKER)
      "Player"
    elsif full_winning_line?(TTTGame::COMPUTER_MARKER)
      "Computer"
    else
      false
    end
  end

  def reset
    (1..9).each { |key| squares[key] = Square.new }
  end

  def full_winning_line?(marker)
    WINNING_LINES.any? do |line|
      line.map { |square_num| squares[square_num].mark }
          .all? marker
    end
  end
end

class Square
  attr_accessor :mark

  def initialize
    @mark = TTTGame::EMPTY_MARKER
  end

  def to_s
    mark
  end

  def empty?
    mark == TTTGame::EMPTY_MARKER
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class TTTGame
  attr_reader :board, :human, :computer
  EMPTY_MARKER = " "
  PLAYER_MARKER = "X"
  COMPUTER_MARKER = "O"

  def initialize
    @board = Board.new
    @human = Player.new(PLAYER_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
  end

  def human_place_mark
    puts "What square do you want to mark? #{board.empty_squares}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.empty_squares.include? square
      puts "Sorry, it's not a valid square number, try again:"
    end
    board.assign(PLAYER_MARKER, square)
    board.display
  end

  def computer_place_mark
    square = board.empty_squares.sample
    board.assign(COMPUTER_MARKER, square)
    board.display
  end

  def someone_won?
    !!board.winner
  end

  def board_full?
    board.empty_squares.empty?
  end

  def display_welcome_message
    system "clear"
    puts
    puts "Welcome to Tic-Tac-Toe"
    puts "----------------------"
    puts "press enter key to start"
    gets
  end

  def display_result
    if board.winner
      puts "#{board.winner} won."
    else
      puts "It's a tie."
    end
  end

  def display_goodbye_message
    puts "Thank you for playing."
  end

  def play_again?
    puts
    puts "Do you want to play again? (y/n)"
    choice = nil
    loop do
      choice = gets.chomp
      break if %(y n).include? choice.downcase
      puts "Invalid choice, please try again."
    end
    choice == "y"
  end

  def reset_game
    board.reset
    board.display
  end

  def play
    display_welcome_message
    loop do
      reset_game
      loop do
        human_place_mark
        break if someone_won? || board_full?

        computer_place_mark
        break if someone_won? || board_full?
      end
      display_result
      break unless play_again?
    end
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
