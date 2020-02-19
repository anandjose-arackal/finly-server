# == Schema Information
#
# Table name: email_events
#
#  id          :bigint           not null, primary key
#  email_id    :bigint           not null
#  event       :string(255)      not null
#  link        :string(255)
#  received_at :datetime
#  event_id    :string(255)
#  payload     :text(4294967295)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uuid        :string(36)
#  deleted_at  :datetime
#

require 'rails_helper'

RSpec.describe EmailEvent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
