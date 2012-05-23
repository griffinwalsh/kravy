require 'spec_helper'

describe Kravy::AI do
  let(:game) { stub("game") }
  let(:ai) { Kravy::AI.new(game) }

  subject { ai }

  it { should respond_to(:new_round) }
  it { should respond_to(:hand=) }
  it { should respond_to(:new_turn) }
  it { should respond_to(:put_card) }
  it { should respond_to(:eat_row) }
end
