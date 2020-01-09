# == Schema Information
#
# Table name: company_groups
#
#  id                 :bigint           not null, primary key
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  default_company_id :integer
#

require 'rails_helper'

RSpec.describe CompanyGroup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
