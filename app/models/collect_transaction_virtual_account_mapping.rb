# == Schema Information
#
# Table name: collect_transaction_virtual_account_mappings
#
#  id                     :integer          not null, primary key
#  virtual_account_id     :integer
#  transaction_purpose_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class CollectTransactionVirtualAccountMapping < ApplicationRecord

end
