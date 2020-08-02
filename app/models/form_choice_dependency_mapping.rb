# == Schema Information
#
# Table name: form_choice_dependency_mappings
#
#  id                    :bigint           not null, primary key
#  dependency_id         :string(36)       not null
#  dependent_choice_id   :string(36)       not null
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  controlling_choice_id :string(255)
#

class FormChoiceDependencyMapping < ApplicationRecord
  include TemplateClonable

  belongs_to :dependency, class_name: "FormChoiceDependency", optional: true

  def reference(controlling_choice, dependent_choice)
    self.template_reference[:controlling_choice] = controlling_choice
    self.template_reference[:dependent_choice] = dependent_choice
  end

  def as_json(options = {})
    {
        id: id,
        dependent_choice_id: dependent_choice_id,
        deleted_at: deleted_at,
        created_at: created_at,
        updated_at: updated_at,
        controlling_choice_id: controlling_choice_id,
    }
  end
end
