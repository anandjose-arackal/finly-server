class Forms::API::Validation
  include Forms::API::Rule::DSL

  attr_accessor :entity_path

  def initialize(entity_path, &block)
    self.entity_path = entity_path
    instance_eval &block if block_given?

    raise "No rules provided for the validation" if rules.blank?
  end

end