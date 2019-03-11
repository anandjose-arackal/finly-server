# == Schema Information
#
# Table name: user_ips
#
#  id                                :bigint(8)        not null, primary key
#  ip                                :string(255)      not null
#  ip_type                           :string(255)      not null
#  user_id                           :integer          not null
#  status_id                         :integer          not null
#  verification_mode                 :string(255)
#  verification_key                  :string(255)
#  verification_code_sent_at         :datetime
#  verified_at                       :datetime
#  verification_code_count           :integer
#  verification_code_failed_attempts :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

require 'rails_helper'

RSpec.describe UserIp, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
