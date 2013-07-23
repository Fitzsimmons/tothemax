require 'spec_helper'
require 'counter_hash'

describe CounterHash do
  it "adds two hashes" do
    lhs = {key: 2}
    rhs = {key: 2}

    c = CounterHash.new(lhs)
    c.add(rhs)

    expect(c.result).to eq({key: 4})
  end

  it "merges new values" do
   lhs = {key: 2} 
   rhs = {key: 2, nu: 5}

   c = CounterHash.new(lhs)
   c.add(rhs)

   expect(c.result).to eq({key: 4, nu: 5})
  end
end