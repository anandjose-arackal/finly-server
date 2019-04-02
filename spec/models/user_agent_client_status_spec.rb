# == Schema Information
#
# Table name: user_agent_client_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe UserAgentClientStatus, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
