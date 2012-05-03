module Kravy
  class AI
    def initialize(game)
      @game = game
      @iterations = 1000
      @opp_stars_factor = 0.5
    end

    attr_accessor :iterations
    attr_accessor :opp_stars_factor

    attr_accessor :hand

    def new_turn
      my_stars_by_hand = Hash.new(0)
      opp_stars_by_hand = Hash.new(0)

      deck = RandomDeck.new((@game.all_cards - @game.used_cards).to_a)

      @iterations.times do
        deck.save do
          human_cards = (1...@game.player_count).map do
            deck.take_random
          end

          @hand.each do |hand|
            my_stars, opponent_stars = resolve_cards(hand, human_cards)
            my_stars_by_hand[hand] += my_stars
            opp_stars_by_hand[hand] += opponent_stars
          end
        end
      end

      @put_card = @hand.min_by do |card|
        my_stars_by_hand[card] - opp_stars_by_hand[card] * @opp_stars_factor
      end

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

  end
end
