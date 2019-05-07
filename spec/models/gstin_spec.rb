# == Schema Information
#
# Table name: gstins
#
#  id                       :bigint           not null, primary key
#  gstin                    :string(255)
#  legal_name_of_business   :string(255)
#  state                    :string(255)
#  date_of_registration     :date
#  constitution_of_business :string(255)
#  taxpayer_type            :string(255)
#  status                   :string(255)
#  api_response             :text(16777215)
#  api_provider             :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  address                  :text(65535)
#  trade_name               :string(255)
#

require 'rails_helper'

RSpec.describe Gstin, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
