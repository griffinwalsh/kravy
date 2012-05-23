module Kravy
  class RandomDeck

    def initialize(cards, probabilities)
      @cards = cards.dup
      @probabilities = probabilities
      @card_stack = []
    end

    def save
      @card_stack.push @cards
      @cards = @cards.dup
      yield
      @cards = @card_stack.pop
    end

    def take_random
      unless @cards.empty?
        index = rand(@cards.size)
        card = @cards[index]
        @cards[index] = @cards.last
        @cards.pop
        card
      else
        raise RuntimeError, "The deck is empty"
      end
    end

  end
end
