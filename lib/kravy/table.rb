module Kravy
  class Table

    def initialize(game, rows = [])
      @game = game
      @rows = rows.dup
    end

    attr_reader :rows

    def clear
      @rows = []
    end

    def empty?
      @rows.all? &:empty?
    end

    def add_row(row)
      @rows << row
      @rows.sort!
    end

    def put_card(card)
      @added_to = nil
      @taken_row = nil

      best_index = nil
      best_distance = nil

      (0...@rows.size).each do |i|
        distance = card.number - @rows[i].last.number
        if distance > 0 and (best_distance.nil? or distance < best_distance)
          best_index = i
          best_distance = distance
        end
      end

      if best_index
        if @rows[best_index].size >= @game.row_size
          @taken_row = @rows[best_index]
          eat_row(best_index, card)
          :took
        else
          @added_to = @rows[best_index].dup
          @rows[best_index] << card
          :added
        end
      else
        :eat
      end
    end

    attr_reader :added_to
    attr_reader :taken_row

    def eat_row(index, new_card)
      @rows[index] = [new_card]
      @rows.sort!
    end

    def fork
      Table.new(@game, @rows.map(&:dup))
    end

    def min_star_row
      (0...@rows.size).min_by { |i| Table.count_the_stars(@rows[i]) }
    end

    def self.count_the_stars(row)
      row.map(&:stars).inject(0) {|a,b| a+b}
    end

  end
end
