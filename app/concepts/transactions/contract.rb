module Transactions::Contract
  extend ActiveSupport::Concern

  # included do
  #   feature Parent
  # end

  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      errors.add attr, err_list
    end
  end

  SKIP_KEYS = %w(contract_row_input contract_input contract_root contract_parent).freeze

  # Build the JSON input from the current state of the form
  def self.to_form(data)
    if data.is_a?(Reform::Form)
      json = {}
      fields = data.instance_variable_get("@fields")
      fields.each_pair do |key, value|
        next if SKIP_KEYS.include?(key.to_s)

        json[key] = to_form(value)
      end
      return json
    elsif data.is_a?(Array)
      list = []
      data.each do |item|
        list << to_form(item)
      end
      return list
    else
      data.as_json
    end
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

  # Build the JSON input from the current state of the form
  def to_form
    Transactions::Contract.to_form(self)
  end

  module Parent
    def self.included(includer)
      includer.class_eval do
        property :contract_parent, virtual: true
        property :contract_root, virtual: true
        property :contract_input, virtual: true
        property :contract_row_input, virtual: true, deserializer: {parse_pipeline: ->(*) { -> (input, represented:, **) { represented.contract_row_input = input } }}

        def contract_input
          contract_root&.contract_row_input
        end

        def contract_root
          super || self
        end
      end
    end

    def build_twin(dfn, value, options = {})
      properties = {
          contract_parent: self,
          contract_root: self.contract_root,
      }

      super(dfn, value, options.merge(properties))
    end
  end

end