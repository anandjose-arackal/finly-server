# == Schema Information
#
# Table name: billing_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#

require 'rails_helper'

RSpec.describe BillingType, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
