require 'set'

module Kravy
  class Game

    def initialize
      @ai = AI.new(self)
      @table = Table.new(self)
    end

    attr_reader :ai
    attr_reader :table

    def self.setup_attr(name)
      define_method(name) do |new = nil|
        instance_variable_set("@#{name}".to_sym, new || instance_variable_get("@#{name}".to_sym))
      end
    end

    setup_attr :player_count
    setup_attr :hand_size
    setup_attr :card_count
    setup_attr :row_count
    setup_attr :row_size

    def new_round
      if @put_cards and not @put_cards.empty?
        raise RuntimeError, "There seem to be some cards to be processed with #next_card"
      end

      if @ai_hand and not @ai_hand.empty?
        raise RuntimeError, "There are still some cards in players' hand"
      end

      @used_cards = Set.new
      @ai_hand = []
      @table.clear
      nil
    end

    attr_reader :table

    def ai_hand(*card_numbers)
      if card_numbers.size == @hand_size
        cards = numbers_to_cards(card_numbers)
        @ai.hand = cards.dup
        @ai_hand = cards.dup
        use_cards cards
      else
        raise ArgumentError, "Initial hand size is #@hand_size"
      end
      nil
    end

    def initial_cards(*card_numbers)
      if card_numbers.size == @row_count
        cards = numbers_to_cards(card_numbers)

        @table.clear
        cards.each do |card|
          @table.add_row([card])
        end

        use_cards cards
      else
        raise ArgumentError, "There are #@row_count rows"
      end
      nil
    end

    def new_turn
      if @put_cards and not @put_cards.empty?
        raise RuntimeError, "There seem to be some cards to be processed with #next_card"
      end

      if @table.empty?
        raise RuntimeError, "The table is empty, don't you want to call #initial_cards first?"
      end

      if @ai_hand.empty?
        raise RuntimeError, "The players' hand is empty, time to new round"
      end

      @ai.new_turn
      @ai_card = @ai.put_card

      if @ai_hand.include? @ai_card
        @ai_hand.delete @ai_card
      else
        raise RuntimeError, "AI wanted to put #{@ai_card.number}, but it does not have it :)"
      end
      nil
    end

    def ai_card
      @ai_card.number
    end

    def human_cards(*card_numbers)
      if card_numbers.size == @player_count - 1
        cards = numbers_to_cards(card_numbers)
        use_cards(cards)
        @put_cards = (cards + [@ai_card]).sort
      else
        raise RuntimeError, "There are #{@player_count - 1} human players"
      end
      nil
    end

    def next_card
      if @card_to_eat
        raise RuntimeError, "Card #@card_to_eat has to be eaten first"
      end

      unless @put_cards.empty?
        card = @put_cards.shift

        case @table.put_card(card)
        when :added
          [:added, card.number, @table.added_to.map(&:number)]
        when :took
          [:took, card.number, @table.taken_row.map(&:number)]
        when :eat
          if card == @ai_card
            index = @ai.eat_row
            row = @table.rows[index].map(&:number)
            @table.eat_row(index, card)
            [:ai_ate, card.number, row]
          else
            @card_to_eat = card
            [:eat, card.number]
          end
        else
          raise RuntimeError, "Oh, @table.put_card returned something silly :("
        end
      end
    end

    def eat(card_number_from_row)
      if @card_to_eat
        card = Kravy::Card.new(card_number_from_row)

        index = nil
        (0...@row_count).each do |i|
          if @table.rows[i].include? card
            index = i
            break
          end
        end

        if index
          @table.eat_row(index, @card_to_eat)
          @card_to_eat = nil
        else
          raise ArgumentError, "There is now row containing card #{card.number}"
        end
      else
        raise RuntimeError, "There is no card which should eat some row"
      end

      nil
    end

    def show_table
      @table.rows.map { |row| row.map &:number }
    end

    private

    def numbers_to_cards(card_numbers, check_unused = true)
      card_numbers.map do |number|
        card = Card.new(number)

        unless valid_card? card
          raise ArgumentError, "Card #{number} is not valid in this game"
        end

        if check_unused and used_card? card
          raise ArgumentError, "Card #{number} has already been used in this round"
        end

        card
      end
    end

    def valid_card?(card)
      card.number >= 1 and card.number <= @card_count
    end

    def used_card?(card)
      @used_cards.include? card
    end

    def use_card(card)
      @used_cards.add card
    end

    def use_cards(cards)
      cards.each { |c| use_card c }
    end

  end
end
