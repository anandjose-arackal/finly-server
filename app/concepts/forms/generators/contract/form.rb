class Forms::Generators::Contract::Form

  def self.build(form)
    sections = form.sections.includes(entities: {entities: {entities: {entities: [:entities]}}})
    # dependencies = form.dependencies
    Class.new(Reform::Form) do
      # Fixme: this applies custom fields for the entire document root, need to scope it down based on the section specific custom fields
      # Fixme: Low Priority
      # instance_eval &Forms::Generators::Contracts::EntityBuilder::CustomField.setup(form.entities.root.custom_fields)

      sections.each do |section|
        section.entities.root.each do |entity|
          entity.contract(self)
        end
      end

      # dependencies.each do |dependency|
      #   class_eval &dependency.contract
      # end
    end
  end

end