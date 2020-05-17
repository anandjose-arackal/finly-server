module Transactions::Contract
  extend ActiveSupport::Concern

  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      errors.add attr, err_list
    end
  end

  included do
    property :contract_root, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.contract_root = RequestStore[:contract_root] } }}
    property :contract_parent, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.contract_parent = RequestStore[:contract_parent] } }}
    property :contract_input, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.contract_input = RequestStore[:contract_input] } }}
    property :row_input, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.row_input = input } }}
  end

  class_methods do
    def property(name, options = {}, &block)
      args = {contract: self, type: :property, name: name, options: options, block: block}
      Transactions::Contracts::PreProcessor.execute(args)
      super(args[:name], args[:options], &args[:block])
    end

    def collection(name, options = {}, &block)
      args = {contract: self, type: :collection, name: name, options: options, block: block}
      Transactions::Contracts::PreProcessor.execute(args)
      super(args[:name], args[:options], &args[:block])
    end
  end

  def validate(input)
    # Fixme : This a workaround for setting root, parent and input of the contract. Need a better way
    RequestStore[:contract_input] = input if RequestStore[:contract_input].nil?
    RequestStore[:contract_root] = self if RequestStore[:contract_root].nil?
    RequestStore[:contract_parent] = self
    result = super(input)
    RequestStore[:contract_root] = nil
    RequestStore[:contract_input] = nil
    RequestStore[:contract_parent] = nil
    result
  end

end