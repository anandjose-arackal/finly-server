class Filters::Sanitizer < Transactions::API

  def self.perform(query)
    result = Filters::Sanitizer.(query: query)
    return result['query'] if result.success?

    query
  end

  skip_user_authorization!

  pass :parse_query_if_string
  pass :parse_group_if_string

  # Primarily to handle get requests where the q value is sent as a string instead of JSON
  def parse_query_if_string(context, query:, **)
    return unless query.class.name == String.name

    context["query"] = JSON.parse(query)
  end

  # Primarily to handle get requests where the g value is sent as a string instead of JSON
  def parse_group_if_string(context, query:, **)
    return unless query["g"].class.name == String.name

    context["query"]["g"] = JSON.parse(query["g"])
  end

end