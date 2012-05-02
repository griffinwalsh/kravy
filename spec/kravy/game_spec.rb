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

  describe "#ai_card"

  describe "#human_cards"

  describe "#next_card"

  describe "#eat"

  describe "#show_table"

end
