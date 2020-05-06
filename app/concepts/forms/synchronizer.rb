class Forms::Synchronizer

  def self.call
    Forms::Router.forms.each { |form| Forms::Synchronizer.sync(form) }
  end

  def self.sync(form)
    raise "Model not found for form #{form.name}" if form.model.blank?

    Company.limit(2).last(1).each do |company|
      form_model = Form.where(klass_name: form.name, company_id: company.id, model: form.model).first_or_create

      form.sections.each do |section|
        sync_section company, form_model, section
      end
      form.dependencies.each do |dependency|
        sync_dependency company, form_model, dependency
      end
    end
  end

  private

  def self.sync_section(company, form_model, section)
    section_model = form_model.sections.find_or_initialize_by(
        name: section.name,
        company_id: company.id,
        form_id: form_model.id
    )
    section_model.update(section.schema) # unless section_model.persisted?

    section.entities.each do |entity|
      sync_entity company, form_model, section_model, entity
    end
  end

  def self.sync_entity(company, form_model, section_model, entity, parent: nil)
    entity_model = section_model.entities.where(form_id: form_model.id, form_section_id: section_model.id, field_key: entity.field_key, parent: parent).first

    unless entity_model.present?
      entity_model = section_model.entities.new entity.schema.except(:section, :choices, :choices_scope)
      entity_model.parent = parent
      # Todo broken because of generalizing choices provider to be reused with filters
      if entity.schema[:choices_scope].present?
        entity_model.choices_scope = entity.schema[:choices_scope].as_json
        if entity.schema&.dig(:choices_scope)&.config[:choices]&.present?
          pos = 0
          choices = []
          entity.schema&.dig(:choices_scope).config[:choices].each do |choice|
            choices << {
                name: choice[:name],
                active: choice[:active],
                company: company,
                form: form_model,
                form_section: section_model,
                form_entity: entity_model,
                position: pos
            }
            pos += 1
          end
          entity_model.assign_attributes(form_entity_choices_attributes: choices)
        end
      end

      entity_model.form = form_model
      entity_model.form_section = section_model
      entity_model.company = company
      unless entity_model.save
        raise "Error saving entity : #{entity_model.errors.full_messages.to_json}"
      end
    end

    entity.entities.each do |child_entity|
      sync_entity company, form_model, section_model, child_entity, parent: entity_model
    end

    entity_model
  end

  def self.sync_dependency(company, form_model, dependency)
    # Todo
    # dependency.find_or_create(company.users.first, form_model)
  end

end