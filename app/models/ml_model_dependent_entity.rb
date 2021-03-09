# == Schema Information
#
# Table name: ml_model_dependent_entities
#
#  id             :bigint           not null, primary key
#  company_id     :integer          not null
#  ml_model_id    :integer          not null
#  form_id        :string(255)      not null
#  form_entity_id :string(255)      not null
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class MlModelDependentEntity < ApplicationRecord
  include TemplateClonable

  belongs_to :company
  belongs_to :ml_model
  belongs_to :form
  belongs_to :form_entity

  def self.system_model(form_entity_path)
    model = self.new
    model.template_reference[:form_entity_path] = entity_key
    model
  end

end
