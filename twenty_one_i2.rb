class Player
  attr_reader :hand, :name

  def initialize(name)
    empty_hands!
    @name = name
  end

  def empty_hands!
    @hand = Hand.new
  end

  def deal(card)
    hand << card
  end

  def display_hand
    puts "#{name}:"
    puts hand.display
  end

  def display_backs
    puts "#{name}:"
    puts hand.display_backs
  end

  def busted?
    total > 21
  end

  def total
    hand.value
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    reset
  end

  def reset
    faces = (2..10).map(&:to_s) + %w[Jack Queen King Ace]
    faces.each { |face| cards << Card.new(face) }
    @cards = cards * 4
    cards.shuffle!
  end

  def take
    cards.shift
  end
end

class Hand
  attr_reader :cards

  def initialize
    @cards = []
  end

  def <<(card)
    cards << card
  end

  def display
    puts delimiter_line
    puts empty_line
    puts card_line
    puts empty_line
    puts delimiter_line
  end

  def display_backs
    puts delimiter_line
    puts empty_line
    puts empty_line
    puts empty_line
    puts delimiter_line
  end

  def delimiter_line
    ([" ----- "] * cards.size).join(" ")
  end

  def empty_line
    (["|     |"] * cards.size).join(" ")
  end

  def hidden_card_line
    (["|  ?  |"] * cards.size).join(" ")
  end

  def value
    higher = cards.map(&:higher_value).sum
    lower = cards.map(&:lower_value).sum
    higher > 21 ? lower : higher
  end
end

class Card
  attr_reader :face

  def initialize(face)
    @face = face
  end

  def lower_value
    case face
    when ("1".."10") then face.to_i
    when "Jack", "Queen", "King" then 10
    else 1
    end
  end

  def higher_value
    case face
    when ("1".."10") then face.to_i
    when "Jack", "Queen", "King" then 10
    else 11
    end
  end

  def to_s
    face
  end
end

class Game
  attr_reader :deck, :player, :dealer

  def initialize
    reset_deck
    @player = Player.new("You")
    @dealer = Player.new("Dealer")
  end

  def reset_play
    reset_deck
    player.empty_hands!
    dealer.empty_hands!
  end

  def reset_deck
    @deck = Deck.new
  end

  def welcome_message
    clear
    puts
    puts "Welcome to twenty-one"
    puts "---------------------"
    puts "Press ENTER to continue"
    gets
  end

  def clear
    system "clear"
  end

  def deal_cards
    2.times { player.deal(deck.take) }
    2.times { dealer.deal(deck.take) }
  end

  def show_cards
    clear
    player.display_hand
    puts
    dealer.display_hand
  end

  def show_initial_cards
    clear
    player.display_hand
    puts
    dealer.display_backs
  end

  def player_turn
    loop do
      puts
      puts "Do you want to (h)it or (s)tay?"
      choice = obtain_player_choice
      case choice
      when "h"
        player.deal(deck.take)
        show_cards
      when "s"
        return
      end
    end
  end

  def obtain_player_choice
    loop do
      choice = gets.chomp.downcase
      return choice[0] if %w[hit stay h s].include? choice
      puts "Sorry, that's not a valid choice"
    end
  end

  def dealer_turn
    until dealer.total >= 17
      dealer.deal(deck.take)
      show_cards
    end
  end

  def show_result
    display_hands_totals
    if tie?
      puts "It's a tie."
    else
      puts "#{winner} won."
    end
  end

  def tie?
    dealer.busted? && player.busted? || dealer.total == player.total
  end

  def winner
    return nil if tie?
    if player.busted?
      "Dealer"
    elsif dealer.busted?
      "Player"
    elsif dealer.total > player.total
      "Dealer"
    else
      "Player"
    end
  end

  def display_hands_totals
    if player.busted?
      puts "You busted."
    else
      puts "Your hand is #{player.total}."
    end
    if dealer.busted?
      puts "Dealer busted."
    else
      puts "Dealer's hand is #{dealer.total}"
    end
  end

  def play_again?
    puts
    puts "Do you want to play again? (y/n)"
    choice = nil
    loop do
      choice = gets.chomp.downcase
      break if %w[y n].include? choice
      puts "Sorry, it's not a valid choice."
    end
    choice == "y"
  end

  def goodbye_message
    puts
    puts "Thank you for playing."
  end

  def start
    welcome_message
    loop do
      reset_play
      deal_cards
      show_initial_cards
      player_turn
      dealer_turn
      show_result
      break unless play_again?
    end
    goodbye_message
  end
end

Game.new.start
