# == Schema Information
#
# Table name: collect_transaction_virtual_account_mappings
#
#  id                     :integer          not null, primary key
#  virtual_account_id     :integer
#  transaction_purpose_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

class CollectTransactionVirtualAccountMapping < ApplicationRecord

end
