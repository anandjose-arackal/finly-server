class Forms::API
  include DynamicAttributes

  class_attr :sections, default: []
  class_attr :dependencies, default: []
  class_attr :model

  def self.section(name, options={}, &block)
    sections << Forms::API::Entity::Section.new(self, name, options, &block)
  end

  def self.dependency(map)
    dependencies << Forms::API::Dependency::Item.new(map)
  end

  def self.find_entity(field_path)
    sections.each do |section|
      entity = section.find_entity field_path
      return entity if entity
    end
    nil
  end

  def self.fetch(user)
    ::Form.find_by(company_id: user.company_id, klass_name: self.name)
  end

end