# == Schema Information
#
# Table name: form_dependencies
#
#  id                    :bigint           not null, primary key
#  company_id            :integer          not null
#  dependency_type_id    :integer          not null
#  controlling_user_id   :integer          not null
#  controlling_entity_id :integer          not null
#  dependent_entity_id   :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'rails_helper'

RSpec.describe FormDependency, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
