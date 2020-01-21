class Forms::Definitions::Section
  include DynamicAttributes
  include Forms::Definitions::Registry
  attr_accessor :name, :block, :form

  def initialize(form, name, &block)
    self.form = form
    self.name = name
    self.block = block
    instance_eval &block if block.present?
  end

  def section
    name
  end

end