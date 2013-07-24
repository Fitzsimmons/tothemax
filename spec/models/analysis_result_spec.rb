require 'spec_helper'

describe AnalysisResult do
  let(:tweet1) { double("tweet1", :id => 1, :attrs => {id: 1}, :text => "12345", :retweet? => false) }
  let(:tweet2) { double("tweet2", :id => 2, :attrs => {id: 2}, :text => "123", :retweet? => false) }
  let(:tweet3) { double("tweet3", :id => 3, :attrs => {id: 3}, :text => "12345", :retweet? => false) }
  let(:page) { [tweet1, tweet2, tweet3] }


  it "successfully merges old and new results" do
    previous_result = create(:analysis_result)

    fake_pager = double("Pager")

    TwitterUserTimelinePager.should_receive(:new).with(previous_result.username).and_return(fake_pager)
    fake_pager.should_receive(:page_back).and_yield([tweet1]).and_return(1)

    AnalysisResult.internal_populate_from_api(previous_result.username)

    previous_result.reload
    expect(previous_result.count).to eq({"5" => 3, "3" => 1})
  end
end
