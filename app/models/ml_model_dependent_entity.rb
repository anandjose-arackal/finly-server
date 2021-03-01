class MlModelDependentEntity < ApplicationRecord
  include TemplateClonable

  belongs_to :company
  belongs_to :ml_model
  belongs_to :form
  belongs_to :form_entity

  def self.system_model(form_entity_key)
    model = self.new
    model.template_reference[:form_entity_key] = entity_key
    model
  end

end
