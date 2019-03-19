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

require 'rails_helper'

RSpec.describe IciciBankConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
