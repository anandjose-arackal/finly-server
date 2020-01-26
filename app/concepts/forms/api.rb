class Forms::API
  include Forms::Contracts::Builder
  include Forms::Filters::Builder
  include DynamicAttributes
  # include Forms::Builders::Configuration

  class_attr :sections, default: []
  class_attr :model

  def self.section(name, &block)
    sections << Forms::Entity::Section.new(self, name, &block)
  end

end