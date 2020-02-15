# == Schema Information
#
# Table name: kotak_bank_configs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

class KotakBankConfig < ApplicationRecord
end
