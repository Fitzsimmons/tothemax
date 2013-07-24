class TwitterUserTimelinePager
  PAGE_SIZE = 200

  def initialize(user)
    @user = user
  end

  def page_back(stop_at = 0, &block)
    raise ArgumentError.new("Must provide a block") unless block

    highest_id = 0
    page = nil

    page_num = 0
    tweet_count = 0

    lowest_id = nil

    while !last_page?(page)
      page = trim_anything_older_than(fetch_page(lowest_id), stop_at)
      page_num += 1
      Rails.logger.info "Started processing page #{page_num}"
      return -1 if page.empty?

      # strange error when using .id, fetch the id out of the attrs hash manually when using max
      highest_id = [highest_id, page.max{|t| t.attrs[:id]}.id].max
      lowest_id = page.last.id # assumptions were made
      Rails.logger.info "Lowest id for this pass: #{lowest_id}"

      yield page

      tweet_count += page.count
      Rails.logger.info "Processed #{tweet_count} tweets"
    end

    return highest_id
  end

  def fetch_page(max_id = nil)
    options = {count: PAGE_SIZE, trim_user: true}
    options.merge!({max_id: max_id-1}) if max_id

    return Twitter.user_timeline(@user, options)
  end

  def page_has_tweet_id(page, tweet_id)
    return page.map(&:id).include?(tweet_id)
  end

  def trim_anything_older_than(page, oldest_tweet_id)
    return page.reject do |tweet|
      tweet.id <= oldest_tweet_id
    end
  end

  def last_page?(page)
    # There is an unknown case where twitter won't return all 200 results, but there's still way more. Need to find out a better way to decide when to keep paging. For now, this works, but it is confusing and causes awkwardness in tests

    !page.nil? && page.count < PAGE_SIZE/2
  end
end
