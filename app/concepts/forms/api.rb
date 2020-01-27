class Forms::API
  include Forms::Contracts::DSL
  include Forms::Filters::Builder
  include DynamicAttributes
  # include Forms::Builders::Configuration

  class_attr :sections, default: []
  class_attr :model

  def self.section(name, &block)
    sections << Forms::Entity::Section.new(self, name, &block)
  end

  def self.find_entity(field_path)
    sections.each do |section|
      entity = section.find_entity field_path
      return entity if entity
    end
    nil
  end

end