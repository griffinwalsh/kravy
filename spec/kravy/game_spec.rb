require 'spec_helper'

describe Kravy::Game do

  let(:game) { Kravy::Game.new }

  describe "setup methods" do
    def self.setup_method(method)
      describe "##{method}" do
        it "sets and gets #{method}" do
          game.__send__(method.to_sym, 42)
          game.__send__(method.to_sym).should == 42
        end
      end
    end

    setup_method :player_count
    setup_method :hand_size
    setup_method :card_count
    setup_method :row_count
    setup_method :row_size
  end

  before do
    game.player_count 3
    game.hand_size 4
    game.card_count 100
    game.row_count 4
    game.row_size 3

    game.ai.iterations = 10
  end

  describe "#new_round" do
    it "clears the table" do
      game.new_round
      game.table.should be_empty
    end

    it "returns nil" do
      game.new_round.should be_nil
    end

    context "when there are still some cards from former turn" do
      before do
        game.new_round
        game.ai_hand 1, 2, 3, 4
        game.initial_cards 10, 20, 30, 40

        [[11, 12], [21, 22], [31, 32]].each do |human_cards|
          game.new_turn
          game.human_cards *human_cards
          3.times { game.next_card }
        end

        game.new_turn
        game.human_cards 41, 42
        2.times { game.next_card }
      end

      it "raises RuntimeError" do
        expect { game.new_round }.to raise_exception(RuntimeError)
      end
    end

    context "when the players still have some cards in hand" do
      before do
        game.new_round
        game.ai_hand 1, 2, 3, 4
        game.initial_cards 10, 20, 30, 40

        [[11, 12], [21, 22], [31, 32]].each do |human_cards|
          game.new_turn
          game.human_cards *human_cards
          3.times { game.next_card }
        end
      end

      it "raises RuntimeError" do
        expect { game.new_round }.to raise_exception(RuntimeError)
      end
    end
  end

  describe "#ai_hand" do
    it "sets the AI's hand" do
      game.new_round
      game.ai_hand 1, 2, 3, 4
      game.ai.hand.map(&:number).sort.should == [1, 2, 3, 4]
    end

    context "wrong number of cards is given" do
      it "raises an ArgumentError" do
        game.new_round
        expect { game.ai_hand 1, 2, 3 }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#initial_cards" do
    it "prepares the table" do
      game.new_round
      game.initial_cards 10, 20, 30, 40
      game.table.rows.map{|r|r.map(&:number)}.should == [[10], [20], [30], [40]]
    end

    context "when wrong number of cards is given" do
      it "raises ArgumentError" do
        game.new_round
        expect { game.initial_cards 10, 20, 30, 40, 50 }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#new_turn" do
    before do
      game.new_round
      game.initial_cards 10, 20, 30, 40
      game.ai_hand 1, 2, 3, 4
    end

    it "calls ai#new_turn" do
      game.ai.should_receive(:new_turn)
      game.ai.stub(:put_card => Kravy::Card.new(1))
      game.new_turn
    end

    it "asks for ai#put_card" do
      game.ai.should_receive(:put_card).and_return(Kravy::Card.new(1))
      game.new_turn
    end

    context "when there are still cards from turn before" do
      before do
        game.new_turn
        game.human_cards 21, 22
        game.next_card
      end

      it "raises RuntimeError" do
        expect { game.new_turn }.to raise_error(RuntimeError)
      end
    end

    context "when there are no initial cards" do
      it "raises RuntimeError" do
        my_game = Kravy::Game.new
        my_game.player_count 3
        my_game.hand_size 4
        my_game.row_count 5
        my_game.row_size 3
        my_game.card_count 100

        my_game.new_round
        my_game.ai_hand 1, 2, 3, 4
        expect { my_game.new_turn }.to raise_error(RuntimeError)
      end
    end

    context "when players do not have anything in their hands" do
      before do
        [21, 31, 41, 51].each do |human_card|
          game.new_turn
          game.human_cards human_card, human_card + 1
          3.times { game.next_card }
        end
      end

      it "raises RuntimeError" do
        expect { game.new_turn }.to raise_error(RuntimeError)
      end
    end
  end

  describe "#ai_card" do
    before do
      game.new_round
      game.ai_hand 1, 2, 3, 4
      game.initial_cards 10, 20, 30, 40

      game.ai.stub(:put_card => Kravy::Card.new(2))
      game.new_turn
    end

    it "returns the number of the card put by AI" do
      game.ai_card.should == 2
    end
  end

  describe "#human_cards" do
    before do
      game.new_round
      game.ai_hand 1, 2, 3, 34
      game.initial_cards 10, 20, 30, 40
    end

    it "stores cards put by human players to be processed along with AI's card" do
      game.ai.stub(:put_card => Kravy::Card.new(34))
      game.new_turn
      game.human_cards 32, 42
      3.times { game.next_card }
      game.show_table.should == [[10], [20], [30, 32, 34], [40, 42]]
    end

    context "given wrong number of cards" do
      it "raises ArgumentError" do
        expect { game.human_cards 32, 33, 35 }
      end
    end

  end

  describe "#next_card" do
    before do
      game.new_round
      game.ai_hand(*ai_hand)
      game.initial_cards(*initial_cards)

      game.ai.stub(:put_card).and_return *((_ = *ai_put_card).map{|n| Kravy::Card.new(n)})
      game.new_turn
      game.human_cards(*human_cards)
    end

    let(:ai_hand) { [1, 2, 3, 34] }
    let(:initial_cards) { [10, 20, 30, 40] }
    let(:ai_put_card) { 34 }
    let(:human_cards) { [50, 70] }

    it "processes the cards from lower to higher" do
      game.next_card[1].should == 34
      game.next_card[1].should == 50 
      game.next_card[1].should == 70
    end

    it "returns nil when there are no remaining cards" do
      3.times { game.next_card }
      game.next_card.should be_nil
    end

    context "when human cards were not specified before" do
      let(:ai_put_card) { [34, 1] }

      before do
        loop { break if game.next_card.nil? }
        game.new_turn
      end

      it "raises RuntimeError" do
        expect { game.next_card }.to raise_error(RuntimeError)
      end
    end

    shared_examples "the return value" do |*expected_elems|
      let(:return_value) { game.next_card }

      describe "the return value" do
        expected_elems.each_with_index do |expected_elem, index|
          describe "element #{index}" do
            it "is #{expected_elem.inspect}" do
              return_value[index].should == expected_elem
            end
          end
        end

        it "has #{expected_elems.size} elements" do
          return_value.should have(expected_elems.size).elements
        end
      end
    end

    context "when the card can be added to a row without taking" do
      let(:ai_hand) { [1, 2, 3, 12] }
      let(:ai_put_card) { 12 }
      let(:human_cards) { [13, 42] }

      before do
        game.next_card
      end

      include_examples "the return value", :added, 13, [10, 12]
    end

    context "when the card takes a row" do
      let(:ai_put_card) { 34 }
      let(:human_cards) { [33, 35] }

      before do
        game.next_card
        game.next_card
      end

      include_examples "the return value", :took, 35, [30, 33, 34]
    end

    context "when AI's card has to eat a row" do
      let(:ai_put_card) { 3 }

      before do
        game.ai.stub(:eat_row => 2)
      end

      include_examples "the return value", :ai_ate, 3, [30]

      it "calls ai#eat_row and eats that row" do
        game.ai.should_receive(:eat_row).and_return(2)
        game.next_card

        game.show_table.should == [[3], [10], [20], [40]]
      end
    end

    context "when human's card has to eat a row" do
      let(:ai_put_card) { 34 }
      let(:human_cards) { [5, 6] }

      include_examples "the return value", :eat, 5

      it "sets card to eat" do
        game.next_card
        game.card_to_eat.should == 5
      end

      it "prevents next calls to #next_card until a row is eaten" do
        game.next_card
        expect { game.next_card }.to raise_error(RuntimeError)
        game.eat 20
        expect { game.next_card }.not_to raise_error(RuntimeError)
      end
    end
  end

  describe "#eat"

  describe "#show_table"

end
