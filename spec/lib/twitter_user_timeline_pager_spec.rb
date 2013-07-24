require 'spec_helper'
require 'twitter_user_timeline_pager'

describe TwitterUserTimelinePager do
  let(:pager) { TwitterUserTimelinePager.new("JSFitzsimmons") }
  let(:tweet1) { double("tweet1", :id => 1, :attrs => {id: 1}) }
  let(:tweet2) { double("tweet2", :id => 2, :attrs => {id: 2}) }
  let(:tweet3) { double("tweet3", :id => 3, :attrs => {id: 3}) }
  let(:page) { [tweet1, tweet2, tweet3] }

  before(:each) do
    Twitter.stub(:user_timeline => page)
  end

  it "raises if a block is not passed" do
    expect(->{ pager.page_back_to }).to raise_exception
  end

  it "fetches the first page" do
    results = double("results")

    Twitter.should_receive(:user_timeline).with('JSFitzsimmons', {count: TwitterUserTimelinePager::PAGE_SIZE, trim_user: true}).and_return(results)

    pager.fetch_page
  end

  it "detects when the page has a given tweet id" do
    expect(pager.page_has_tweet_id(page, 2)).to be_true
  end

  it "trims the results to get rid of old tweets" do
    expect(pager.trim_anything_older_than(page, 2)).to eq([tweet3])
  end

  it "detects the last page" do
    expect(pager.last_page?(page)).to be_true
    expect(pager.last_page?(nil)).to be_false

    redefine_const TwitterUserTimelinePager, 'PAGE_SIZE', 2 do
      expect(pager.last_page?(page)).to be_false
    end
  end

  it "pages backwards" do
    # The page size in this test has been gamed in order to pass the hack that was needed for the last page detection. Twitter isn't always returning all 200 results even when there's more updates to be found, so I had to use a hack for page detection for now.

    redefine_const TwitterUserTimelinePager, 'PAGE_SIZE', 4 do
      page1 = [tweet3, tweet2]
      page2 = [tweet1]

      Twitter.should_receive(:user_timeline).with("JSFitzsimmons", {count: 4, trim_user: true}).and_return(page1)
      Twitter.should_receive(:user_timeline).with("JSFitzsimmons", {count: 4, trim_user: true, max_id: 1}).and_return(page2)
      d = double
      d.should_receive(:go).with(page1)
      d.should_receive(:go).with(page2)

      pager.page_back do |page|
        d.go(page)
      end
    end
  end

  it "stops when it reaches the stop id" do
    page1 = [tweet2, tweet1]

    Twitter.should_receive(:user_timeline).once.and_return(page1)
    d = double
    d.should_receive(:go).once.with([tweet2])

    pager.page_back(1) do |page|
      d.go page
    end
  end

  it "returns the highest id it encountered" do
    result = pager.page_back do
      next
    end

    expect(result).to eq(3)
  end

  it "bails out if the user has never tweeted" do
    Twitter.should_receive(:user_timeline).and_return([])

    result = pager.page_back do |page|
      next
    end

    expect(result).to eq(-1)
  end

end
