require 'spec_helper'

describe Kravy::Table do

  let(:game) { stub("game") }
  let(:table) { Kravy::Table.new(game) }

  def card_no(n)
    Kravy::Card.new(n)
  end

  describe "#clear" do
    it "deletes all the rows" do
      table.add_row([])
      table.add_row([card_no(2), card_no(3)])
      table.add_row([card_no(4)])
      table.clear
      table.rows.should == []
    end
  end

  describe "#empty?" do
    context "when there are no rows" do
      it "returns true" do
        table.should be_empty
      end
    end

    context "when all rows are empty" do
      it "returns true" do
        table.add_row []
        table.add_row []
        table.should be_empty
      end
    end

    context "when some row is not empty" do
      it "returns false" do
        table.add_row []
        table.add_row [card_no(1), card_no(2)]
        table.add_row []
        table.should_not be_empty
      end
    end
  end

  describe "#add_row" do
    it "adds the given row to the table" do
      table.add_row([card_no(1), card_no(2)])
      table.rows.should == [[card_no(1), card_no(2)]]
    end

    it "keeps the rows sorted by card numbers" do
      table.add_row([card_no(10)])
      table.add_row([card_no(3)])
      table.add_row([card_no(5)])

      table.rows.should == [
        [Kravy::Card.new(3)],
        [Kravy::Card.new(5)],
        [Kravy::Card.new(10)]
      ]
    end
  end

  describe "#put_card" do
    before do
      game.stub(:row_size => 2)
      table.add_row([card_no(10)])
      table.add_row([card_no(20), card_no(22)])
      table.add_row([card_no(80)])
    end

    context "when all row ends are higher than the card" do
      it "returns :eat" do
        table.put_card(card_no(8)).should == :eat
      end
    end

    context "when nearest row lower than the card is found" do
      context "when the row is shorter than game.row_size" do
        it "returns :added" do
          table.put_card(card_no(12)).should == :added
        end

        it "adds the card to the row" do
          table.put_card(card_no(82))
          table.rows.should == [
            [card_no(10)],
            [card_no(20), card_no(22)],
            [card_no(80), card_no(82)]
          ]
        end

        it "puts the content of the row to #added_to" do
          table.put_card(card_no(82))
          table.added_to.should == [card_no(80)]
        end
      end

      context "when the row is full" do
        it "returns :took" do
          table.put_card(card_no(24)).should == :took
        end

        it "replaces the row with the card" do
          table.put_card(card_no(24))
          table.rows.should == [
            [card_no(10)],
            [card_no(24)],
            [card_no(80)]
          ]
        end

        it "puts the content of the row to #taken_row" do
          table.put_card(card_no(24))
          table.taken_row.should == [card_no(20), card_no(22)]
        end
      end
    end
  end

  describe "#eat_row" do
    before do
      table.add_row([card_no(10)])
      table.add_row([card_no(20), card_no(22)])
      table.add_row([card_no(80)])
    end

    it "replaces row with the given index with the card" do
      table.eat_row(2, card_no(7))
      table.rows.should == [
        [card_no(7)],
        [card_no(10)],
        [card_no(20), card_no(22)]
      ]
    end
  end

  describe "#fork" do
    it "returns a copy" do
      table.add_row([card_no(10)])
      table.add_row([card_no(20)])
      forked = table.fork
      forked.rows.should == [[card_no(10)], [card_no(20)]]
    end

    describe "the copy" do
      context "when it is modified" do
        it "does not affect the parent" do
          table.add_row([card_no(10)])
          table.add_row([card_no(20)])
          forked = table.fork
          forked.eat_row(0, card_no(11))
          forked.rows.should == [[card_no(11)], [card_no(20)]]
          table.rows.should == [[card_no(10)], [card_no(20)]]
        end
      end
    end
  end

  describe "#min_star_row" do
    it "returns index of row having minimal sum of stars" do
      table.add_row([card_no(1), card_no(2)])
      table.add_row([card_no(100)])
      table.add_row([card_no(17), card_no(55)])
      table.add_row([card_no(11), card_no(5)])
      table.min_star_row.should == 0
    end
  end
end
