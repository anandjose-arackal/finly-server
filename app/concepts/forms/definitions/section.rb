Dir["#{Rails.root}/app/concepts/forms/definitions/types/*.rb"].each {|file| load file}
class Forms::Definitions::Section
  include DynamicAttributes
  include Forms::Definitions::Registry
  attr_accessor :name, :block, :form

  class_attr :type

  type :simple

  def initialize(form, name, &block)
    self.form = form
    self.name = name
    self.block = block
    instance_eval &block if block.present?
  end

  def section
    name
  end

  def type
    self.class.type
  end
end