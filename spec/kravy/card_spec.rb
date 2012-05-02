require 'spec_helper'

describe Kravy::Card do

  describe ".new" do
    it "returns the same instance for same numbers" do
      card_a = Kravy::Card.new(2)
      card_b = Kravy::Card.new(2)

      card_a.should equal(card_b)
    end
  end

  describe "#stars" do

    def self.card_stars(card_number, stars)
      describe "card #{card_number}" do
        it "has #{stars} stars" do
          Kravy::Card.new(card_number).stars.should == stars
        end
      end
    end

    describe "multiplies of 5" do
      card_stars 5, 2
      card_stars 15, 2
      card_stars 85, 2
    end

    describe "multiplies of 10" do
      card_stars 10, 3
      card_stars 20, 3
      card_stars 90, 3
    end

    describe "multiplies of 11" do
      card_stars 11, 5
      card_stars 33, 5
      card_stars 77, 5
    end

    describe "multiplies of both 11 and 5" do
      card_stars 55, 7
      card_stars 165, 7
    end

    describe "other cards" do
      card_stars 1, 1
      card_stars 74, 1
    end

  end

end

