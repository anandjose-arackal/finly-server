class QueryLogger
  DEFAULT_OPTIONS = { :bad_count => 8, :bad_time => 5000 }

  class << self
    attr_accessor :queries, :paused

    def reset
      self.queries = {}
    end

    def log(query)
      if paused?
        yield
      else
        result = nil
        time = Benchmark.realtime do
          result = yield
        end
        queries[queries.length] = {time: time, query: query} if log_query?(query)
        result
      end
    end

    def time
      queries.map{|query|  query.last[:time]}.reduce(0,:+)
    end

    def count
      queries.size
    end

    def bad?(options = {})
      options = options.reverse_merge(DEFAULT_OPTIONS)
      count >= options[:bad_count] or time >= options[:bad_time]
    end

    def paused?
      paused
    end

    private

    def log_query?(query)
      query =~ /^(select|create|update|delete|insert)\b/i
    end
  end
end