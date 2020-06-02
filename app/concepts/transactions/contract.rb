module Transactions::Contract
  extend ActiveSupport::Concern

  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      errors.add attr, err_list
    end
  end

  # Build the JSON input from the current state of the form
  def self.to_form(contract)
    HashUtils.deep_reject(contract.to_nested_hash) { |k, v| %w(row_input contract_input contract_root contract_parent).include?(k)}
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

end