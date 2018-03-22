require "pry"

class Player
  def initialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
  end

  def hit
  end

  def stay
  end

  def busted?
  end

  def total
    # definitely looks like we need to know about "cards" to produce some total
  end
end

class Dealer
  def initialize
    # seems like very similar to Player... do we even need this?
  end

  def deal
    # does the dealer or the deck deal?
  end

  def hit
  end

  def stay
  end

  def busted?
  end

  def total
  end
end

class Participant
  # what goes in here? all the redundant behaviors from Player and Dealer?
end

class Deck
  def initialize
    create_cards
    @deck.shuffle!
  end

  def create_cards
    cards_values = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace] * 4
    @deck = cards_values.map {|value| Card.new(value)}
  end

  def deal
    # does the dealer or the deck deal?
  end
end

class Card
  attr_reader :value

  def initialize(value)
    @value = value
  end
end


# class Game
#   def start
#     deal_cards
#     show_initial_cards
#     player_turn
#     dealer_turn
#     show_result
#   end
# end

# Game.new.start