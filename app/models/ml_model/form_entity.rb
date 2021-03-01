# == Schema Information
#
# Table name: ml_models
#
#  id              :bigint           not null, primary key
#  company_id      :integer          not null
#  parent_type     :string(255)
#  parent_id       :bigint
#  type            :string(255)      not null
#  config          :text(4294967295)
#  built_at        :datetime
#  build_schedule  :string(255)
#  track_schedule  :string(255)
#  build_duration  :integer
#  tracked_at      :datetime
#  algorithm       :string(255)
#  target_key      :string(255)      not null
#  target_key_type :string(255)      not null
#  split_key       :string(255)
#  split_key_type  :string(255)
#  model_klass     :string(255)
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pmml            :text(65535)
#
class MlModel::FormEntity < MlModel
  include TemplateClonable

  belongs_to :form
  has_many :dependent_entity_mappings, class_name: 'MlModelDependentEntity', foreign_key: :ml_model_id

  validates :form, presence: true
  validates :parent, presence: true

  def self.system_model(model_klass:, form_entity_key:, dependent_entity_keys: [])
    model = self.new(
      build_schedule: 'weekly',
      target_key: form_entity_key,
      target_key_type: 'category',
      split_key: 'submitted_at',
      split_key_type: 'datetime',
      model_klass: model_klass
    )
    model.template_reference[:form_entity_key] = form_entity_key
    dependent_entity_keys.each do |dependent_entity_key|
      dependent_entity_mapping = model.dependent_entity_mappings.new
      dependent_entity_mapping.template_reference[:form_entity_key] = dependent_entity_key
    end
    model
  end

  def prepare_record(record)
    # Todo
  end

  def prepare_prediction(data)
    # Todo
  end

end
