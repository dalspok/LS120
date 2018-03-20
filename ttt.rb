class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.select { |_, square| square.unmarked? }.keys
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts
    puts "     |     |     "
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    puts "     |     |     "
    puts "-----|-----|-----"
    puts "     |     |     "
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    puts "     |     |     "
    puts "-----|-----|-----"
    puts "     |     |     "
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  "
    puts "     |     |     "
    puts
  end
  # rubocop:enable Metrics/AbcSize

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  # check for last empty square in line
  def critical_square(marker)
    initial = Square::INITIAL_MARKER
    check_lines_for_constellation(initial, marker, initial)
  end

  # check for two empty squares in line
  def two_empty_in_line(marker)
    initial = Square::INITIAL_MARKER
    check_lines_for_constellation(marker, initial, initial)
  end

  def middle_if_empty
    @squares[5].marker == Square::INITIAL_MARKER ? 5 : nil
  end

  private

  def check_lines_for_constellation(single, double, searched)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      offensive = one_to_two_constellation(squares, single, double, searched)
      return line[offensive] if offensive
    end
    nil
  end

  def one_to_two_constellation(squares, single, double, searched)
    squares_values = squares.map(&:marker)
    double_marker_count = squares_values.count(double)
    single_marker_count = squares_values.count(single)
    if (double_marker_count == 2) && (single_marker_count == 1)
      found_marker_index = squares_values.index(searched)
    end
    found_marker_index
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "
  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :score, :name, :marker
  FINAL_SCORE = 5

  def initialize
    reset_score
  end

  def reset_score
    self.score = 0
  end

  def increment_score
    self.score += 1
  end

  def won_whole_game?
    score >= FINAL_SCORE
  end
end

class TTTGame
  WHO_STARTS_GAME = "choose" # human, computer, choose
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new
    @computer = Player.new
    welcome_and_settings
  end

  def play
    loop do
      display_board
      loop do
        current_player_moves
        display_board_clear
        break if board.full? || board.someone_won?
      end
      display_result
      break if final_score_reached? || !continue?
      reset_play
    end
    display_goodbye_message
  end

  private

  def welcome_and_settings
    display_welcome_message
    set_names
    set_markers
    set_who_starts
  end

  def set_names
    @human.name = pick_name("your")
    @computer.name = pick_name("computer")
  end

  def pick_name(whose)
    puts "What's #{whose} name?"
    answer = nil
    loop do
      answer = gets.chomp
      break unless answer.strip.empty?
      puts "Sorry, not a valid choice, try again:"
    end
    answer
  end

  def set_markers
    @human.marker = pick_marker("yourself")
    @computer.marker = pick_marker("computer")
  end

  def pick_marker(whom)
    puts "Choose a marker for #{whom} (one character, except empty space):"
    answer = nil
    loop do
      answer = gets.chomp
      break if answer.size == 1 && answer != " "
      puts "Sorry, not a valid choice, try again:"
    end
    answer
  end

  def set_who_starts
    case WHO_STARTS_GAME
    when "human"
      @first_moving = human.marker
      clear
    when "computer"
      @first_moving = computer.marker
      clear
    else
      @first_moving = prompt_who_starts
    end
    @current_marker = @first_moving
  end

  def prompt_who_starts
    answer = nil
    loop do
      puts "Do you want to start? (y/n)"
      answer = gets.chomp.downcase
      break if ["y", "n", "yes", "no"].include? answer
      puts "Sorry, not a valid choice"
    end
    clear
    case answer
    when "y", "yes"
      human.marker
    else
      computer.marker
    end
  end

  def continue?
    input = nil
    puts
    loop do
      puts "Press ENTER to continue (or 'q' to quit)"
      input = gets.chomp.downcase
      break if input == "q" || input == ""
      puts "Invalid input"
    end
    input != "q"
  end

  def display_winner(winner)
    winner.increment_score
    display_board_clear
    who = winner == human ? "You" : "Computer"
    puts "#{who} won!"
  end

  def display_result
    if board.winning_marker == human.marker
      display_winner(human)

    elsif board.winning_marker == computer.marker
      display_winner(computer)
    else
      puts "It's a tie. Board is full."
    end
  end

  def display_welcome_message
    clear
    puts "Welcome to Tic Tac Toe!"
    puts
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
  end

  def clear
    system("clr") || system("clear")
  end

  def display_board_clear
    clear
    display_board
  end

  def display_board
    puts "You are a #{human.marker}, computer is a #{computer.marker}"
    puts
    puts "#{human.name}:#{computer.name} | #{human.score}:#{computer.score}"
    board.draw
  end

  def final_score_reached?
    human.won_whole_game? || computer.won_whole_game?
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ["y", "n", "yes", "no"].include? answer
      puts "Sorry, not a valid choice"
    end
    ["y", "yes"].include? answer
  end

  def human_moves
    puts "Choose a square (#{board.unmarked_keys.join(', ')}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include? square
      puts "Sorry, that's not a valid choice"
    end
    board[square] = human.marker
  end

  def joinor(arr, delimiter = ", ", end_joiner = "or")
    case arr.size
    when (0..1)
      return arr[0].to_s
    when 2
      final_delimiter = " "
    else
      final_delimiter = delimiter
    end
    end_joiner += " "
    first_part = arr[0..-2].join(delimiter)
    second_part = "#{final_delimiter}#{end_joiner}#{arr[-1]}"
    first_part + second_part
  end

  def computer_moves
    best_move = best_computer_move
    board[best_move] = computer.marker
  end

  def best_computer_move
    critical_offensive = board.critical_square(computer.marker)
    critical_defensive = board.critical_square(human.marker)
    offensive = board.two_empty_in_line(computer.marker)
    middle = board.middle_if_empty
    critical_offensive || critical_defensive ||
      offensive || middle || board.unmarked_keys.sample
  end

  def reset_play
    board.reset
    @first_moving = if @first_moving == human.marker
                      computer.marker
                    else
                      human.marker
                    end
    @current_marker = @first_moving
    clear
  end
end

game = TTTGame.new
game.play
