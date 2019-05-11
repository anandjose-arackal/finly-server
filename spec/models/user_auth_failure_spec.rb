# == Schema Information
#
# Table name: user_auth_failures
#
#  id         :bigint(8)        not null, primary key
#  user_id    :integer          not null
#  locked     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe UserAuthFailure, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
