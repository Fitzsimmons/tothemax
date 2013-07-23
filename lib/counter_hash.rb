class CounterHash
  def initialize(start = nil)
    @internal_hash = start || {}
  end

  def add(rhs)
    @internal_hash.merge!(rhs) do |key, oldval, newval|
      newval + oldval
    end
  end

  def result
    @internal_hash
  end
end