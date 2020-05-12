# == Schema Information
#
# Table name: form_dependencies
#
#  id                     :bigint           not null
#  company_id             :integer          not null
#  controlling_entity_id  :string(255)      not null
#  dependent_entity_id    :string(255)      not null
#  created_by_id          :integer          not null
#  updated_by_id          :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  form_id                :string(255)      not null
#  controlling_entity_key :string(255)
#  dependent_entity_key   :string(255)
#

require 'rails_helper'

RSpec.describe FormDependency, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
