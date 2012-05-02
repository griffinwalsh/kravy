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

end
