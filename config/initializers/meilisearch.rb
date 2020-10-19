module UpdatedTimeout

  def self.timeout
    60
  end

  def self.max_retries
    2
  end

  def http_config(query_params, body)
    body = body.to_json unless body.nil?
    {
        headers: instance_variable_get("@headers"),
        query: query_params,
        body: body,
        timeout: instance_variable_get("@options")[:timeout] || UpdatedTimeout.timeout,
        open_timeout: instance_variable_get("@options")[:timeout] || UpdatedTimeout.timeout,
        read_timeout: instance_variable_get("@options")[:timeout] || UpdatedTimeout.timeout,
        max_retries: instance_variable_get("@options")[:max_retries] || UpdatedTimeout.max_retries
    }.compact
  end

end
MeiliSearch::Client.include UpdatedTimeout
MeiliSearch::Index.include UpdatedTimeout
[MeiliSearch::Client, MeiliSearch::Index].each do |client|
  client.default_timeout UpdatedTimeout.timeout
  client.open_timeout UpdatedTimeout.timeout
  client.read_timeout UpdatedTimeout.timeout
  client.write_timeout UpdatedTimeout.timeout
end