class Forms::Contracts::Builders::Form

  def self.call(form)
    # FixMe : proper inclusion of conditions, validations and dependencies to avoid N+1
    sections = form.sections.includes(entities: {entities: {entities: {entities: [:entities]}}})
    # dependencies = form.dependencies
    Class.new(Reform::Form) do
      # Forms::Contracts::Builders::CustomField.(self, form.entities.root.custom_fields)

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