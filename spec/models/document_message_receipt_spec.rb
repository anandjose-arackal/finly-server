# == Schema Information
#
# Table name: document_message_receipts
#
#  id                        :bigint           not null, primary key
#  user_id                   :integer          not null
#  receiptable_document_id   :integer          not null
#  receiptable_document_type :string(255)      not null
#  document_message_id       :integer          not null
#  browser_push_sent_at      :datetime
#  app_push_sent_at          :datetime
#  email_sent_at             :datetime
#  read_at                   :datetime
#  trashed_at                :datetime
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe DocumentMessageReceipt, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
