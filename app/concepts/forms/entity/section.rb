class Forms::Entity::Section
  include DynamicAttributes
  include Forms::Entity::Registry
  attr_accessor :name, :block, :form, :field_path

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