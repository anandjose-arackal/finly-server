class Forms::Contracts::Helpers::SetupBase

  def self.call(reform)
    reform.send(:property, :contract_root, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.contract_root = RequestStore[:contract_root] } }})
    reform.send(:property, :contract_parent, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.contract_parent = RequestStore[:contract_parent] } }})
    reform.send(:property, :contract_input, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.contract_input = RequestStore[:contract_input] } }})
    reform.send(:property, :row_input, virtual: true, deserializer: {parse_pipeline: ->(*) { ->(input, represented:, **) { represented.row_input = input } }})
  end

end