# == Schema Information
#
# Table name: itz_cash_dmt_senders
#
#  id              :integer          not null, primary key
#  mobile_number   :string(255)      not null
#  registration_id :string(255)      not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status_id       :integer          not null
#  otp_verified    :boolean          default(FALSE), not null
#

class ItzCashDmtSender < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :status, optional: true, class_name: 'ItzCashDmtSenderStatus'
  has_many :beneficiaries, class_name: 'ItzCashDmtBeneficiary'

  validates :user_id, presence: true
  validates :mobile_number, presence: true
  validates :registration_id, presence: true

end
