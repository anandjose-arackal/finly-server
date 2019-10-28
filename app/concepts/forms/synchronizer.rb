class Forms::Synchronizer
  extend ActiveSupport::Concern

  def self.call
    Forms::API.master.each { |model, form| Forms::Synchronizer.sync(form) }
  end

  def self.sync(form)
    raise "Model not found for form #{form.name}" if form.model.blank?

    Company.all.each do |company|
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

  def self.sync_entity(company, form_model, section_model, entity)
    entity_model = section_model.entities.where(form_id: form_model.id, form_section_id: section_model.id, field_key: entity.field_key).first_or_create

  end

end