# == Schema Information
#
# Table name: notify_users
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  company_id    :integer
#  document_id   :integer
#  document_type :string(255)
#  enabled       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#

require 'rails_helper'

RSpec.describe NotifyUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
