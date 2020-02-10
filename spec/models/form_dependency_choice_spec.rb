# == Schema Information
#
# Table name: form_dependency_choices
#
#  id                        :bigint           not null, primary key
#  company_id                :integer          not null
#  form_dependency_id        :integer          not null
#  controlling_choice_id     :integer          not null
#  is_choice_selected        :boolean
#  dependent_entity_required :boolean
#  dependent_entity_visible  :boolean
#  dependent_entity_editable :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe FormDependencyChoice, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
