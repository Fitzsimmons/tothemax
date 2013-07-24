require 'counter_hash'

class StatusAnalysis

  def initialize(raw_api_result)
    @raw = raw_api_result
  end

  def status_length_frequency
    frequency_counter = CounterHash.new

    @raw.each do |tweet|
      next if tweet.retweet?
      frequency_counter.add(add_unit(clamp(tweet.text.length, 140)))
    end

    return frequency_counter.result
  end

  private

  def add_unit(count)
    return {count => 1}
  end

  def clamp(val, max)
    if val > max
      return max
    end
    return val
  end
end
