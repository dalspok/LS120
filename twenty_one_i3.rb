class Participant
  attr_reader :cards

  def initialize
    reset
  end

  def take(card)
    @cards << card
  end

  def reset
    @cards = []
  end

  def display
    puts "#{self.class} (#{total})"
    display_cards
  end

  def display_cards
    puts " ----- " * num_of_cards
    puts "|     |" * num_of_cards
    puts cards.map { |card| "|  #{card.value.center(2)} |" }.join
    puts "|     |" * num_of_cards
    puts " ----- " * num_of_cards
  end

  def num_of_cards
    @cards.size
  end

  def busted?
    total > 21
  end

  def total
    higher_total > 21 ? lower_total : higher_total
  end

  def higher_total
    @cards.reduce(0) do |sum, card|
      if Deck::CARD_PERSONS_VALUES.include? card.value
        sum + 10
      elsif Deck::CARD_ACE_VALUE.include? card.value
        sum + 11
      else
        sum + card.value.to_i
      end
    end
  end

  def lower_total
    @cards.reduce(0) do |sum, card|
      if Deck::CARD_PERSONS_VALUES.include? card.value
        sum + 10
      elsif Deck::CARD_ACE_VALUE.include? card.value
        sum + 1
      else
        sum + card.value.to_i
      end
    end
  end
end

class Player < Participant
  def hit_or_stay
    puts "Do you want to (H)it or (S)tay?"
    choice = nil
    loop do
      choice = gets.chomp.downcase
      break if %w[h s].include? choice
      puts "Sorry, it's not a correct choice. Try again."
    end
    choice == "h" ? :hit : :stay
  end
end

class Dealer < Participant
  attr_reader :hidden_cards

  def reset
    super
    @hidden_cards = true
  end

  def uncover
    @hidden_cards = false
  end

  def display
    total_or_cover = hidden_cards ? "" : "(#{total})"
    puts "#{self.class} #{total_or_cover}"
    display_cards
  end

  def display_cards
    if hidden_cards
      puts " ----- " * num_of_cards
      puts "|     |" * num_of_cards
      puts "|  X  |" * num_of_cards
      puts "|     |" * num_of_cards
      puts " ----- " * num_of_cards
    else super
    end
  end
end

class Deck
  attr_reader :cards
  CARD_PERSONS_VALUES = %w[J Q K]
  CARD_ACE_VALUE = %w[A]
  CARD_VALUES = (2..10).map(&:to_s) + CARD_PERSONS_VALUES + CARD_ACE_VALUE

  def initialize
    @cards = []
    reset
  end

  def reset
    all_values = (CARD_VALUES * 4).shuffle
    all_values.each { |value| @cards << Card.new(value) }
  end

  def deal
    @cards.pop
  end
end

class Card
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def to_s
    @value
  end
end

class Game
  attr_reader :player, :dealer, :deck

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def display_welcome_message
    system "clear"
    puts "Welcome to twenty-one game."
    puts "Press ENTER to continue"
    gets
  end

  def player_turn
    loop do
      choice = player.hit_or_stay
      break if choice == :stay
      player.take(deck.deal)
      display_cards
      break if player.busted?
    end
  end

  def dealer_turn
    dealer.uncover
    dealer.take(deck.deal) while dealer.total < 17
    display_cards
  end

  def display_cards
    system "clear"
    player.display
    dealer.display
  end

  def initial_deal
    2.times { player.take(deck.deal) }
    2.times { dealer.take(deck.deal) }
  end

  def determine_winner
    if player.busted?
      :Dealer
    elsif dealer.busted?
      :Player
    elsif tie?
      :Tie
    else
      player.total < dealer.total ? :Dealer : :Player
    end
  end

  def tie?
    player.total == dealer.total
  end

  def display_results
    if player.busted?
      puts "You busted. Dealer wins."
    elsif dealer.busted?
      puts "Dealer busted. You win."
    elsif tie?
      puts "It's a tie."
    elsif player.total < dealer.total
      puts "Dealer wins."
    else
      puts "Player wins."
    end
  end

  def play_again?
    puts "Do you want to play again? (y/n)"
    choice = nil
    loop do
      choice = gets.chomp.downcase
      break if %w[y n].include? choice
      puts "Sorry, it's not a correct choice. Try again."
    end
    choice == "y"
  end

  def display_goodbye_message
    puts "Thanks for playing."
  end

  def reset_game
    deck.reset
    player.reset
    dealer.reset
  end

  def play
    display_welcome_message
    loop do
      reset_game
      initial_deal
      display_cards
      player_turn
      dealer_turn unless player.busted?
      display_results
      break unless play_again?
    end
    display_goodbye_message
  end
end

Game.new.play
