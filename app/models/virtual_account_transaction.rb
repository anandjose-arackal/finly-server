# == Schema Information
#
# Table name: virtual_account_transactions
#
#  id                         :integer          not null, primary key
#  beneficiary_account_number :string(255)
#  beneficiary_account_ifsc   :string(255)
#  transfer_type              :string(255)
#  beneficiary_full_name      :string(255)
#  transfer_id                :string(255)
#  transfer_timestamp         :string(255)
#  transfer_currency          :string(255)
#  transfer_amount            :string(255)
#  remitter_account_no        :string(255)
#  remitter_account_ifsc      :string(255)
#  remitter_account_type      :string(255)
#  remitter_full_name         :string(255)
#  remitter_address           :string(255)
#  note                       :string(255)
#  credited_at                :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class VirtualAccountTransaction < ActiveRecord::Base


end
