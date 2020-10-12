# == Schema Information
#
# Table name: kotak_bank_configs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class KotakBankConfig < ApplicationRecord
  belongs_to :company, optional: true
end
