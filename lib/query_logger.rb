class QueryLogger
  DEFAULT_OPTIONS = {:bad_count => 8, :bad_time => 5000}

  class << self
    attr_accessor :paused

    def queries
      RequestStore.store[:queries]
    end

    def reset
      RequestStore.store[:queries] = {}
    end

    def log(query)
      reset if self.queries.nil?
      if paused?
        yield
      else
        result = nil
        time = Benchmark.realtime do
          result = yield
        end
        length = self.queries.length
        self.queries[length] = {time: time, query: query} if log_query?(query)
        result
      end
    end

    # Summaries the queries based on SELECT * FROM * WHERE
    # Format : [{count, time, model, query_groups: [type, count, time]}]
    def summary
      summary_regex = /(\w+)\s.*FROM `\s*(\w+)`/i
      summary = {}
      self.queries.each do |length, query_hash|
        query = query_hash[:query]
        time = query_hash[:time]
        query_group = query.match(summary_regex).to_s
        model = query_group.scan(/\w+/).last
        if summary[model].nil?
          summary[model] = {count: 0, time: 0, model: model, query_groups: []}
        end
        summary[model][:count] += 1
        summary[model][:time] += time
        query_group_hash = summary[model][:query_groups].select {|hash| hash[:type] == query_group}
        query_group_hash = query_group_hash&.first
        if query_group_hash.blank?
          query_group_hash = {type: query_group, count: 0, time: 0}
          summary[model][:query_groups] << query_group_hash
        end
        query_group_hash[:count] += 1
        query_group_hash[:time] += time
      end
      summary.values
    end

    def time
      self.queries.map {|query| query.last[:time]}.reduce(0, :+)
    end

    def count
      self.queries.size || 0
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