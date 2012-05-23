require 'spec_helper'

describe Kravy::RandomDeck do

  let(:cards) { [10,20,30,40].map{|n| Kravy::Card.new(n)} }

  def make_deck
    Kravy::RandomDeck.new(cards, nil)
  end

  before do
    srand(10)
  end

  describe "#take_random" do
    it "takes a random card from given cards" do
      10.times do
        deck = make_deck
        card = deck.take_random
        [10, 20, 30, 40].should include(card.number)
      end
    end

    it "does not return the same card twice" do
      10.times do
        deck = make_deck
        first_card = deck.take_random
        second_card = deck.take_random
        first_card.should_not == second_card
      end
    end

    it "does not affect the array of cards given to .new" do
      card_array = [1,2,3].map{|n| Kravy::Card.new(n)}.freeze
      deck = Kravy::RandomDeck.new(card_array, nil)
      expect { deck.take_random }.not_to raise_error
    end

    context "no cards remaining" do
      it "raises RuntimeError" do
        deck = make_deck
        4.times { deck.take_random }
        expect { deck.take_random }.to raise_error(RuntimeError)
      end
    end

    context "inside block given to #save" do
      it "does not return card taken before #save" do
        10.times do
          deck = make_deck
          taken = deck.take_random
          deck.save do
            3.times do
              deck.take_random != taken
            end
          end
        end
      end
    end

    context "after #save finished" do
      it "may return card taken inside #save" do
        returned_taken = false

        20.times do
          deck = make_deck
          taken = nil
          deck.save do
            taken = deck.take_random
          end
          returned_taken ||= taken == deck.take_random
        end

        returned_taken.should be_true
      end
    end
  end

end
