# == Schema Information
#
# Table name: icici_transaction_callbacks
#
#  id         :bigint           not null, primary key
#  AGGRNAME   :string(255)
#  AGGRID     :string(255)
#  URN        :string(255)
#  UNIQUEID   :string(255)
#  REQUESTID  :string(255)
#  TXNSTATUS  :string(255)
#  UTRNUMBER  :string(255)
#  CORPID     :string(255)
#  USERID     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  reconciled :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe IciciTransactionCallback, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
