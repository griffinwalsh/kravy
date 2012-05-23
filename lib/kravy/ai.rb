module Kravy
  Infinity ||= 1.0 / 0.0

  class AI
    def initialize(game)
      @game = game
      @iterations = 1000
      @opp_stars_factor = 0.3
      @expected_factor = 0.8
    end

    attr_accessor :iterations
    attr_accessor :opp_stars_factor
    attr_accessor :expected_factor

    attr_accessor :hand

    def new_round
      @card_expected = (0..@game.card_count).map { 1.0 }
    end

    def new_turn
      @game.used_cards.each do |c|
        @card_expected[c.number] = 0.0
      end

      apply_expectations

      my_stars_by_card = Hash.new(0)
      opp_stars_by_card = Hash.new(0)

      deck = RandomDeck.new((@game.all_cards - @game.used_cards).to_a, @card_expected)

      @iterations.times do
        deck.save do
          human_cards = (1...@game.player_count).map do
            deck.take_random
          end

          @hand.each do |card|
            my_stars, opponent_stars = resolve_cards(card, human_cards)
            my_stars_by_card[card] += my_stars
            opp_stars_by_card[card] += opponent_stars
          end
        end
      end

      @put_card = @hand.min_by do |card|
        my_stars_by_card[card] - opp_stars_by_card[card] * @opp_stars_factor
      end

      @hand.delete(@put_card)

      compute_expectations
    end

    def put_card
      @put_card
    end

    def eat_row
      @game.table.min_star_row
    end

    private

    def resolve_cards(my_card, human_cards)
      table = @game.table.fork

      my_stars = 0
      opponent_stars = 0

      (human_cards + [my_card]).sort.each do |card|
        stars = 0

        case table.put_card(card)
        when :took
          stars = Table.count_the_stars(table.taken_row)
        when :eat
          index = table.min_star_row
          stars = Table.count_the_stars(table.rows[index])
          table.eat_row(index, card)
        end

        if card == my_card
          my_stars += stars
        else
          opponent_stars += stars
        end
      end

      [my_stars, opponent_stars]
    end

    def apply_expectations
      if @expectations
        @expectations.each_pair do |card_no, factor|
          @card_expected[card_no] *= factor
        end
      end
    end

    def compute_expectations
      @expectations = Hash.new(1)

      table = @game.table
      (0...table.rows.size-1).each do |row_i|
        free_places = @game.row_size - table.rows[row_i].length
        free_cards = table.rows[row_i + 1].last.number - table.rows[row_i].last.number

        free_space = [free_places, free_cards].min

        last_card = table.rows[row_i].last.number

        (last_card + 1).upto(last_card + free_space + 1) do |expected|
          @expectations[expected] = @expected_factor
        end
      end
    end

  end
end
