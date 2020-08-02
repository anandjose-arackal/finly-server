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

  belongs_to :dependency, class_name: "FormChoiceDependency"

  def reference(controlling_choice, dependent_choice)
    self.template_reference[:controlling_choice] = controlling_choice
    self.template_reference[:dependent_choice] = dependent_choice
  end
end
