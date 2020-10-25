class Forms::Contracts
  include DynamicAttributes

  def self.Build()
    Transactions::Task.build id: "forms.contracts.build" do |context, flow_options, circuit_options|
      if context[:form].present?
        Builder.with(context)
      else
        Transactions::API.on_error context, :base, 'Form not found'
      end
    end
  end

  class Builder
    def self.with(options)
      options[:'contract.default'] = options[:form].contract(options[:current_user]).new(options[:model])
      true
    end
  end

end
