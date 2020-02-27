# == Schema Information
#
# Table name: bbps_bill_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require 'rails_helper'

RSpec.describe BbpsBillStatus, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
