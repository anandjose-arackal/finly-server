class Forms::Synchronizer
  extend ActiveSupport::Concern

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
    end
  end

  private

  def self.sync_section(company, form_model, section)
    section_model = form_model.sections.where(name: section.name, company_id: company.id, form_id: form_model.id).first_or_create

    section.entities.each do |entity|
      sync_entity company, form_model, section_model, entity
    end
  end

  def self.sync_entity(company, form_model, section_model, entity, parent: nil)
    entity_model = section_model.entities.where(form_id: form_model.id, form_section_id: section_model.id, field_key: entity.field_key, parent: parent).first

    unless entity_model.present?
      entity_model = section_model.entities.new entity.schema.except(:section, :choices)
      entity_model.parent = parent
      if entity.schema&.dig(:scope, :choices)
        pos = 0
        choices = []
        entity.schema&.dig(:scope, :choices).each do |choice|
          choices << choice.merge!(
              {
                  company: company,
                  form: form_model,
                  form_section: section_model,
                  form_entity: entity_model,
                  position: pos
              }
          )
          pos += 1
        end
        entity_model.assign_attributes(choices_attributes: choices)
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

end