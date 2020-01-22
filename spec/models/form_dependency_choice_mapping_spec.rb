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

require 'rails_helper'

RSpec.describe FormDependencyChoiceMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
