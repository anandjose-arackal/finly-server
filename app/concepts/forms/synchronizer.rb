class Forms::Synchronizer
  def self.call(options = {})
    if options[:master].present? && options[:company_id].present?
      master = Forms::Router.forms.filter {|item| item.name == options[:master]}.first
      Forms::Synchronizer.sync(master, company_id)
    else
      Forms::Router.forms.each { |master| Forms::Synchronizer.sync(master) }
    end
  end

  def self.sync(master, company_id = nil)
    form = master.form
    template = Forms::Template.new(form)
    dependency_template = Forms::DependencyTemplate.new(form)

    if company_id.present?
      company = Company.find(company_id)
      user = company.users.first
      # Synchronize form
      template.sync(company_id: company.id, user: user)
      dependency_template.sync(company_id: company.id, user: user)
    else
      # Form.delete_all; FormSection.delete_all; FormEntity.delete_all; FormChoiceDependency.delete_all; FormChoiceDependencyMapping.delete_all; FormRule.delete_all; FormCondition.delete_all; FormConditionAction.delete_all;FormEntityValidation.delete_all;
      Company.limit(2).last(1).each do |company|
        user = company.users.first
        # Synchronize form
        template.sync(company_id: company.id, user: user)
        dependency_template.sync(company_id: company.id, user: user)
      end
    end
  end
end
# class Forms::Synchronizer
#
#   def self.call
#     Forms::Router.forms.each { |form| Forms::Synchronizer.sync(form) }
#   end
#
#   def self.sync(form)
#     raise "Model not found for form #{form.name}" if form.model.blank?
#
#     Company.limit(2).last(1).each do |company|
#       form_model = Form.where(klass_name: form.name, company_id: company.id, model: form.model).first_or_create
#
#       form.sections.each do |section|
#         sync_section company, form_model, section
#       end
#       form.dependencies.each do |id, dependency|
#         sync_dependency company, form_model, dependency
#       end
#     end
#   end
#
#   private
#
#   def self.sync_section(company, form_model, section)
#     section_model = form_model.sections.find_or_initialize_by(
#         section_id: section.section_id,
#         title: section.title,
#         company_id: company.id,
#         form_id: form_model.id
#     )
#     section_model.update(section.schema) # unless section_model.persisted?
#
#     section.entities.each do |entity|
#       sync_entity company, form_model, section_model, entity
#     end
#   end
#
#   def self.sync_entity(company, form_model, section_model, entity, parent: nil)
#     entity_model = section_model.entities.where(form_id: form_model.id, form_section_id: section_model.id, entity_key: entity.entity_key, parent: parent).first
#
#     unless entity_model.present?
#       entity_model = section_model.entities.new entity.schema.except(:section, :choices, :choices_scope)
#       entity_model.parent = parent
#       # Todo broken because of generalizing choices provider to be reused with filters
#       if entity.schema[:choices_scope].present?
#         entity_model.choices_scope = entity.schema[:choices_scope].as_json
#         if entity.schema&.dig(:choices_scope)&.config[:choices]&.present?
#           pos = 0
#           choices = []
#           entity.schema&.dig(:choices_scope).config[:choices].each do |choice|
#             choices << {
#                 name: choice[:name],
#                 active: choice[:active],
#                 company: company,
#                 form: form_model,
#                 form_section: section_model,
#                 form_entity: entity_model,
#                 position: pos
#             }
#             pos += 1
#           end
#           entity_model.assign_attributes(form_entity_choices_attributes: choices)
#         end
#       end
#
#       entity_model.form = form_model
#       entity_model.form_section = section_model
#       entity_model.company = company
#       unless entity_model.save
#         raise "Error saving entity : #{entity_model.errors.full_messages.to_json}"
#       end
#     end
#
#     entity.entities.each do |child_entity|
#       sync_entity company, form_model, section_model, child_entity, parent: entity_model
#     end
#
#     entity_model
#   end
#
#   def self.sync_dependency(company, form_model, dependency)
#     # Todo
#     dependency.sync(company.users.first, form_model)
#   end
#
# end