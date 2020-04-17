# == Schema Information
#
# Table name: form_dependency_choice_mappings
#
#  id                         :bigint           not null
#  company_id                 :integer          not null
#  form_dependency_mapping_id :string(255)      not null
#  dependent_choice_id        :string(255)      not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  deleted_at                 :datetime
#  form_id                    :string(255)      not null
#  dependent_choice_type      :string(255)
#  controlling_entity_id      :string(255)
#  controlling_choice_id      :string(255)
#  controlling_choice_type    :string(255)
#  controlling_entity_key     :string(255)
#  dependent_entity_key       :string(255)
#

require 'rails_helper'

RSpec.describe FormDependencyChoiceMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
