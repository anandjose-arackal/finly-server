# == Schema Information
#
# Table name: form_dependency_choice_mappings
#
#  id                        :bigint           not null, primary key
#  company_id                :integer          not null
#  form_dependency_choice_id :integer          not null
#  dependent_choice_id       :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class FormDependencyChoiceMapping < ApplicationRecord
  belongs_to :company
  belongs_to :form_dependency_choice
  belongs_to :dependent_choice, class_name: 'FormEntityChoice'
end
