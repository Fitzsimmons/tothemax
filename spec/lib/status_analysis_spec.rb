require 'spec_helper'
require 'status_analysis'

describe StatusAnalysis do
  let(:example_tweet_1) { double("tweet 1", text: "12345", retweet?: false) }
  let(:example_tweet_2) { double("tweet 2", text: "123", retweet?: false)}
  let(:example_tweet_3) { double("tweet 3", text: "12345", retweet?: false)}
  let(:example_result) { [example_tweet_1, example_tweet_2, example_tweet_3] }

  let(:default_analyzer) { StatusAnalysis.new(example_result) }

  it "returns a hash with the frequency of status lengths" do
    expect(default_analyzer.status_length_frequency).to eq({ 3 => 1, 5 => 2 })
  end

  it "skips retweets" do
    retweet = double("retweet", text: "12345", retweet?: true)
    example = example_result + [retweet]

    analyzer = StatusAnalysis.new(example)

    expect(analyzer.status_length_frequency).to eq({ 3 => 1, 5 => 2})
  end
end
