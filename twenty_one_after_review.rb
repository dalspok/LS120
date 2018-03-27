class Deck
  def initialize
    create_cards
    shuffle_cards
  end

  def create_cards
    cards_values = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace] * 4
    @deck = cards_values.map { |value| Card.new(value) }
  end

  def deal(how_many_cards)
    @deck.shift(how_many_cards)
  end

  def shuffle_cards
    @deck.shuffle!
  end

  def put_cards_back
    create_cards
  end
end

class Card
  HIGH_ACE_VALUE = 11
  LOW_ACE_VALUE = 1
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def numerical?
    value.to_i.to_s == value
  end

  def pictorial?
    %w[Jack Queen King].include? value
  end
end

class Participant
  attr_accessor :hand, :name, :score

  # rubocop:disable Style/ClassVars
  @@deck = Deck.new
  # rubocop:enable Style/ClassVars

  def initialize(name)
    @name = name
    reset_hand
  end

  def show_hand
    puts "#{name} (#{total}):"
    display_cards(hand)
  end

  # rubocop:disable Metrics/AbcSize
  def display_cards(cards_to_show)
    s = cards_to_show.size
    puts
    puts "  ----- " * s
    puts " |     |" * s
    puts cards_to_show.map { |card| " |" + card.value.center(5) + "|" }.join
    puts " |     |" * s
    puts "  ----- " * s
    puts
  end
  # rubocop:enable Metrics/AbcSize

  def reset_hand
    self.hand = []
  end

  def reset_score
    self.score = 0
  end

  def increment_score
    self.score += 1
  end

  def hit
    take_card
  end

  def busted?
    total > 21
  end

  def difference_from_21
    21 - total
  end

  def total
    return 0 if hand.empty?
    high_value = total_for_ace_value(Card::HIGH_ACE_VALUE)
    low_value = total_for_ace_value(Card::LOW_ACE_VALUE)
    high_value > 21 ? low_value : high_value
  end

  def take_card(how_many_cards=1)
    cards = @@deck.deal(how_many_cards)
    hand.push(*cards)
  end

  private

  def total_for_ace_value(ace_value)
    card_numerical_values = hand.map do |card|
      if card.numerical?
        card.value.to_i
      elsif card.pictorial?
        10
      else
        ace_value
      end
    end
    card_numerical_values.reduce(:+)
  end
end

class Dealer < Participant
  def collect_cards
    @@deck.put_cards_back
  end

  def shuffle_cards
    @@deck.shuffle_cards
  end

  def hide_second_card
    @hide = true
  end

  def show_second_card
    @hide = false
  end

  def show_hand
    if @hide
      total_to_show = nil
      cards_to_show = hand[0..-2] + [Card.new("?")]
    else
      total_to_show = "(#{total})"
      cards_to_show = hand
    end
    puts "#{name} #{total_to_show}:"
    display_cards(cards_to_show)
  end
end

class Game
  attr_reader :player, :dealer, :player_wants_quit
  FINAL_SCORE = 5

  def initialize
    @player = Participant.new("You")
    @dealer = Dealer.new("Dealer")
  end

  def welcome_message
    clear_display
    puts
    puts "Welcome to 21 game"
    puts "We will play till #{FINAL_SCORE} winning rounds."
    puts
  end

  def reset_score
    player.reset_score
    dealer.reset_score
  end

  def clear_display
    (system "clear") || (system "cls")
  end

  def prepare_cards
    clear_hands
    dealer.collect_cards
    dealer.shuffle_cards
  end

  def deal_cards
    dealer.hide_second_card
    player.take_card(2)
    dealer.take_card(2)
  end

  def show_cards
    clear_display
    display_scores
    dealer.show_hand
    player.show_hand
  end

  def display_scores
    puts "-----------------"
    puts "Dealer:You   #{dealer.score}:#{player.score}"
    puts "-----------------"
    puts
  end

  def player_turn
    until player.busted? || obtain_player_choice == "stay"
      player.hit
      show_cards
    end
  end

  def dealer_turn
    dealer.show_second_card
    until dealer.busted? || dealer.total >= 17
      dealer.hit
    end
    show_cards
  end

  def obtain_player_choice
    choice = nil
    loop do
      puts "(H)it or (S)tay?"
      choice = gets.chomp.strip.downcase
      valid_inputs = ["s", "stay", "h", "hit"]
      break if valid_inputs.include? choice
      puts "Sorry, not a valid choice. Try again."
    end
    ["s", "stay"].include?(choice) ? "stay" : "hit"
  end

  def determine_winner
    winner = if tie?
               nil
             elsif dealer.busted?
               player
             elsif player.busted?
               dealer
             elsif player.difference_from_21 < dealer.difference_from_21
               player
             else
               dealer
             end
    show_results(winner)
  end

  def tie?
    (player.busted? && dealer.busted?) || (player.total == dealer.total)
  end

  def show_results(winner=nil)
    winner&.increment_score
    show_cards
    display_if_busted
    winner ? (puts "#{winner.name} won.") : (puts "It's a tie.")
  end

  def display_if_busted
    puts "Dealer have busted." if dealer.busted?
    puts "You have busted." if player.busted?
  end

  def clear_hands
    player.reset_hand
    dealer.reset_hand
  end

  def continue?
    puts "Press ENTER to continue / 'q' to quit"
    loop do
      input = gets.chomp.downcase
      return true if input.empty?
      if input.strip == "q"
        @player_wants_quit = true
        return false
      end
      puts "Sorry, not a valid choice."
    end
  end

  def final_winner?
    !!final_winner
  end

  def final_winner
    if player.score == FINAL_SCORE
      player
    elsif dealer.score == FINAL_SCORE
      dealer
    end
  end

  def display_final_winner
    puts
    puts "**********************"
    puts "Final winner is: #{final_winner.name}"
    puts "**********************"
  end

  def play_again?
    return false if player_wants_quit
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ["y", "n", "yes", "no"].include? answer
      puts "Sorry, not a valid choice"
    end
    ["y", "yes"].include? answer
  end

  def goodbye_message
    puts
    puts "Thanks for playing."
  end

  def play_rounds
    loop do
      clear_display
      deal_cards
      show_cards
      player_turn
      dealer_turn
      determine_winner
      clear_hands
      break if final_winner? || !continue?
    end
  end

  def start
    welcome_message
    return unless continue?
    loop do
      reset_score
      prepare_cards
      play_rounds
      display_final_winner if final_winner?
      break unless play_again?
    end
    goodbye_message
  end
end

Game.new.start
