$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'kravy'
require 'benchmark'

iterations = 10_000_000
elements = 100

array = (0..elements).map { rand }
hash = Hash.new((0..elements).zip(array))
accesses = (0...iterations).map { rand(elements) }

Benchmark.bmbm do |x|
  x.report "array" do
    accesses.each { |index| array[index] }
  end

  x.report "hash" do
    accesses.each { |index| hash[index] }
  end
end

