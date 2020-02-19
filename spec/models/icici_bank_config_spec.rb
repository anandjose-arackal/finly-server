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
#  uuid       :string(36)
#  deleted_at :datetime
#

require 'rails_helper'

RSpec.describe IciciBankConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
