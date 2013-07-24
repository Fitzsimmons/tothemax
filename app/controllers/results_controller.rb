class ResultsController < ApplicationController
  def index
    @results = AnalysisResult.all
  end

  def show
    @result = AnalysisResult.find(params[:id])

    @chart_data = process_count_for_chart(@result.count)
  end

  private

  def process_count_for_chart(count)
    count = count.dup

    max = count.keys.map(&:to_i).max
    (1..max).each do |index|
      count[index.to_s] ||= 0
    end

    data = count.to_a.sort{|a,b| a.first.to_i <=> b.first.to_i}.map(&:second)
    labels = (1..max).to_a

    return {data: data, labels: labels}
  end
end
