# == Schema Information
#
# Table name: api_tokens
#
#  id            :bigint           not null, primary key
#  base_url      :string(255)
#  name          :string(255)
#  username      :string(255)
#  password      :string(255)
#  client_id     :string(255)
#  client_secret :string(255)
#  grant_type    :string(255)
#  content_type  :string(255)
#  token         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
