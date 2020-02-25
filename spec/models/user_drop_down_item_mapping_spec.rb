# == Schema Information
#
# Table name: user_drop_down_item_mappings
#
#  id                :bigint           not null, primary key
#  user_id           :integer
#  drop_down_item_id :integer
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe UserDropDownItemMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
