# == Schema Information
#
# Table name: icici_bank_configs
#
#  id         :bigint           not null, primary key
#  alias_id   :string(255)
#  urn        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  deleted_at :datetime
#

class IciciBankConfig < ApplicationRecord
  belongs_to :company
end
