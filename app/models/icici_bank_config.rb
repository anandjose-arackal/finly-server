# == Schema Information
#
# Table name: icici_bank_configs
#
#  id         :bigint(8)        not null, primary key
#  alias      :string(255)
#  urn        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#

class IciciBankConfig < ApplicationRecord
  belongs_to :company
end
