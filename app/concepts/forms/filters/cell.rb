class Forms::Filters::Cell< Representable::Decorator
  include Representable::JSON

  property :label
  property :hint
  # property :type
  property :field_key
  property :filters
  property :choices, deserializer: -> (input, represented, record:, **)  do
    input.choices if input.consumes_choices?
  end
  property :auto_complete, deserializer: -> (input, represented, record:, **)  do
    input.auto_complete if input.consumes_choices?
  end

end