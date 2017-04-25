# == Schema Information
#
# Table name: itz_cash_dmt_senders
#
#  id              :integer          not null, primary key
#  username        :string(255)      not null
#  mobile_number   :string(255)      not null
#  registration_id :string(255)      not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password        :string(255)
#  status_id       :integer          not null
#  otp_verified    :boolean          default(FALSE), not null
#

class ItzCashDmtSender < ActiveRecord::Base
  belongs_to :user
  has_many :beneficiaries, class_name: 'ItzCashDmtBeneficiary'
  belongs_to :status, class_name: 'ItzCashDmtSenderStatus'

  validates :username, presence: true
  validates :user_id, presence: true
  validates :mobile_number, presence: true
  validates :registration_id, presence: true
end
