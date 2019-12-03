# == Schema Information
#
# Table name: user_field_mappings
#
#  id                     :bigint           not null, primary key
#  user_id                :integer
#  field_configuration_id :integer
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'rails_helper'

RSpec.describe UserFieldMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
