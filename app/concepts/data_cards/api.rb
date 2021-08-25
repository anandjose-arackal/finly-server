# DataCards::API is the base class used for building DataCard adapters
# 
# While its not necessary to inherit this for building new DataCard adapters,
# inheriting it simplifies and standardises the code.
#
# The goal of this API is to use the builder to build the data card JSON
# 
class DataCards::API < Transactions::API

  TYPES ||= ["title", "subtitle", "status", "body", nil, ""].freeze

  schema do
    params do
      required(:id).filled
      required(:route).filled
    end
  end

  # Run all initializations here
  step :init

  # You can add any validations if required here
  step :validate
  # This should ideally be overridden in the sub-class where the logic of building the datacard using the builder is defined
  step :build

  # This is a standard code for building the JSON from the builder
  step :build_result

  def init(context, params:, **)
    # Initialize DataCards::Builder
    context[:builder] = DataCards::Builder.new
    
    true
  end

  # Used for running any validations in sub-classes
  def validate(context, **)
    true
  end

  def build(context, builder:, **)
    # Implement me in the inheriting classes
    false
  end

  def build_result(context, builder:, **)
    context[:result] = builder.as_json

    true
  end

end