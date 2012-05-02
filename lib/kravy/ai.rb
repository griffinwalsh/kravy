module Kravy
  class AI
    def initialize(game)
      @game = game
      @iterations = 1000
    end

    attr_accessor :iterations
    attr_accessor :hand

    def new_turn
      stars = Hash.new(0)

      @iterations.times do
        human_cards = (1...@game.player_count).map do
          Card.new(rand(@game.card_count) + 1)
        end

        @hand.each do |hand|
          my_stars, opponent_stars = resolve_cards(hand, human_cards)
          stars[hand] += my_stars
        end
      end

      @put_card = stars.keys.min_by { |key| stars[key] }
      @hand.delete(@put_card)
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
        end

        if card == my_card
          my_stars += stars
        else
          opponent_stars += stars
        end
      end

      [my_stars, opponent_stars]
    end

  end
end
