class Forms::Contracts::Builders::Form

  def self.call(form, user)
    # FixMe : proper inclusion of conditions, validations and dependencies to avoid N+1
    sections = form.sections.includes(entities: {entities: {entities: {entities: [:entities]}}})
    Class.new(Reform::Form) do
      associate_custom_fields = false
      sections.each do |section|
        associate_custom_fields ||= section.associate_custom_fields
        section.entities.root.each do |entity|
          entity.contract(self, user)
        end
      end

      Forms::Contracts::Builders::CustomField.(self, form.entities.root.custom_fields) if associate_custom_fields.present?

      # dependencies.each do |dependency|
      #   class_eval &dependency.contract
      # end
    end
  end

end