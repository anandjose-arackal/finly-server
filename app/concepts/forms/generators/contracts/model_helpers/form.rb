# Build a contract from an instance of form
module Forms::Generators::Contracts::ModelHelpers::Form
  def contract
    sections = self.sections.includes(entities: {entities: {entities: {entities: [:entities]}}})
    dependencies = self.dependencies
    form = self
    Class.new(Reform::Form) do
      # Fixme: this applies custom fields for the entire document root, need to scope it down based on the section specific custom fields
      # Fixme: Low Priority
      instance_eval &Forms::Generators::Contracts::EntityBuilder::CustomField.setup(form.entities.root.custom_fields)

      sections.each do |section|
        section.entities.root.each do |entity|
          instance_eval &entity.contract
        end
      end

      dependencies.each do |dependency|
        class_eval &dependency.contract
      end
    end
  end
end