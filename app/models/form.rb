# == Schema Information
#
# Table name: forms
#
#  id         :bigint           not null
#  uuid       :string(36)       not null, primary key
#  klass_name :string(255)      not null
#  model      :string(255)      not null
#  company_id :integer          not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  label      :string(255)
#

class Form < ApplicationRecord
  include UUIDHelper, SoftDeletable, TemplateClonable
  # include Forms::Generators::Contracts::ModelHelpers::Form
  # include Forms::Generators::Filters::ModelHelpers::Form

  belongs_to :company, optional: true
  has_many :sections, class_name: 'FormSection', dependent: :destroy
  has_many :entities, class_name: "FormEntity"
  has_many :choice_dependencies, class_name: 'FormChoiceDependency'
  has_many :conditions, class_name: 'FormCondition'
  has_many :validations, class_name: 'FormEntityValidation'
  has_many :prediction_models, class_name: 'MlModel::FormEntityModel'

  scope :preload_for_contract, -> {
    includes(:entities, {
      sections: {
        entities: [:compute_lookup_entity, :form, { conditions: :actions }, :validations, { choice_dependencies: :controlling_entity }, {
          entities: [:compute_lookup_entity, :form, { conditions: :actions }, :validations, { choice_dependencies: :controlling_entity }, {
            entities: [:compute_lookup_entity, :form, { conditions: :actions }, :validations, { choice_dependencies: :controlling_entity }, {
              entities: [:compute_lookup_entity, :form, { conditions: :actions }, :validations, { choice_dependencies: :controlling_entity }, {
                entities: [:compute_lookup_entity, :form, { conditions: :actions }, :validations, { choice_dependencies: :controlling_entity }, {
                  entities: [:compute_lookup_entity, :form, { conditions: :actions }, :validations, { choice_dependencies: :controlling_entity },
                             :entities] }] }] }] }] }] } })
  }

  attr_accessor :preloaded_for_contract

  def preloaded_for_contract?
    !!preloaded_for_contract
  end

  def preload_for_contract!
    return self if preloaded_for_contract?

    self.class.find_for_contract(uuid: self.id)
  end

  def self.find_for_contract(query)
    form = Form.where(query).preload_for_contract.first
    form.preloaded_for_contract = true
    form
  end

  def find_entity(entity_path)
    entity_path = entity_path.to_s
    entities.each do |entity|
      return entity if entity.entity_path == entity_path
    end
    sections.each do |section|
      entity = section.find_entity(entity_path)
      return entity if entity.present?
    end

    nil
  end

  def form_klass
    Object.const_get(klass_name) if klass_name.present?
  end

  def contract(user = nil)
    user ||= RequestStoreUtil.current_user
    Forms::Contracts::Builders::Form.(self, user)
  end

  def authorized?(record, user = nil)
    form_klass.authorized?(record, user)
  end

  def as_json(options = {})
    {
      id: id,
      sections: sections.as_json(options)
    }
  end

  def model
    Object.const_get(super()) if super()
  end

  def import_form?
    [
      'Docs::P2P::Invoices::Import::Form'
    ].include? form_klass.to_s
  end

  def sync_sequence_numbers
    return unless self.model.sequenced_options.present?

    self.model.sequenced_options.each do |seq_options|
      record = self.model.new(company_id: self.company_id)
      generator = Sequenced::Generator.new(record, seq_options)
      sequence_number = generator.next_unique_id_in_sequence - 1
      prefix = generator.get_prefix

      sequence_entity = (self.entities.where(type: 'FormEntity::AutoNumber').filter do |e|
        e.config.dig("sequence", "prefix") == prefix
      end).last

      next unless sequence_entity.present?

      REDIS.set("FormEntity::AutoNumber##{sequence_entity.id}##{prefix}", sequence_number)
    end
  end

end
