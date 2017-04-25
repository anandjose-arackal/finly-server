# == Schema Information
#
# Table name: itz_cash_dmt_beneficiaries
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)      not null
#  middle_name            :string(255)
#  last_name              :string(255)      not null
#  mobile_number          :string(255)      not null
#  relation               :string(255)      not null
#  ifsc_option            :string(255)      not null
#  ifsc_code              :string(255)      not null
#  bank_name              :string(255)
#  branch_name            :string(255)
#  bank_city              :string(255)
#  bank_state             :string(255)
#  account_number         :string(255)      not null
#  beneficiary_name       :string(255)      not null
#  beneficiary_id         :string(255)      not null
#  is_updatable           :boolean          not null
#  itz_cash_dmt_sender_id :integer          not null
#  status_id              :integer          not null
#  type_id                :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  default                :boolean
#

class ItzCashDmtBeneficiary < ActiveRecord::Base
  belongs_to :itz_cash_dmt_sender
  belongs_to :status, class_name: 'ItzCashDmtBeneficiaryStatus'
  belongs_to :type, class_name: 'ItzCashDmtBeneficiaryType'

  scope :reimbursement_accounts, -> { where type_id: ItzCashDmtBeneficiaryType.id_for(:reimbursement_account) }

end
