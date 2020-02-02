module Transactions::Contract
  extend ActiveSupport::Concern

  # Todo helps nested contracts access parent contract and root contracts
  module Parent
    def self.included(includer)
      includer.class_eval do
        property(:parent_contract, virtual: true)
        property(:root_contract, virtual: true)
      end
    end

    def build_twin(dfn, value, options={})
      super(dfn, value, options.merge(root_contract: (self.root_contract || self), parent_contract: self))
    end
  end

  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      errors.add attr, err_list
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

end