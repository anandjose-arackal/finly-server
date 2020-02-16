# == Schema Information
#
# Table name: bank_details_masters
#
#  id          :bigint           not null, primary key
#  name        :string(255)
#  ifsc_prefix :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class BankDetailsMaster < ApplicationRecord
end
