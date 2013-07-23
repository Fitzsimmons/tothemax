require 'counter_hash'
require 'status_analysis'
require 'twitter_user_timeline_pager'

class AnalysisResult < ActiveRecord::Base
  include ResqueDef

  serialize :count, JSON

  resque_def(:populate_from_api) do |username|
    self.internal_populate_from_api(username)
  end

  private

  def self.internal_populate_from_api(username)
    existing_result = AnalysisResult.where(:username => username).first

    existing_count = existing_result.try(:count)
    most_recent_known_id = existing_result.try(:most_recent_known_id) || 0

    counter = CounterHash.new(existing_result)

    pager = TwitterUserTimelinePager.new(username)
    highest_id = pager.page_back(most_recent_known_id) do |page|
      #stringified keys needed here because of limitations of the JSON format which require keys to be strings
      counter.add(StatusAnalysis.new(page).status_length_frequency.stringify_keys)
    end

    if !existing_result
      existing_result = AnalysisResult.new
    end

    existing_result.count = counter.result
    existing_result.username = username
    existing_result.most_recent_known_id = highest_id
    existing_result.save!
  end

end
