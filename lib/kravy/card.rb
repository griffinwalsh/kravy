module Kravy
  class Card

    @cards = Hash.new do |hash, number|
      hash[number] = Card.original_new(number)
    end

    class << self
      unless @new_aliased
        alias_method :original_new, :new
        @new_aliased = true
      end

      def new(number)
        @cards[number]
      end
    end

    def initialize(number)
      @number = number
      @stars = Card.count_the_stars(number)
    end

    attr_reader :number
    attr_reader :stars

    def <=>(other)
      @number <=> other.number
    end

    include Comparable

    def hash
      @number.hash
    end

    private

    def self.count_the_stars(number)
      if number % 10 == 0
        stars = 3
      elsif number % 5 == 0
        stars = 2
      else
        stars = 0
      end

      if number % 11 == 0
        stars += 5
      end

      if stars > 0
        stars
      else
        1
      end
    end

  end
end
