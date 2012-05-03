module Kravy
  class RandomDeck

    def initialize(cards)
      @cards = cards
      @card_stack = []
    end

    def save
      @card_stack.push @cards
      @cards = @cards.dup
      yield
      @cards = @card_stack.pop
    end

    def take_random
      index = rand(@cards.size)
      card = @cards[index]
      @cards[index] = @cards.last
      @cards.pop
      card
    end

  end
end
