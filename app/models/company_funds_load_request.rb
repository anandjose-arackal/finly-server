# == Schema Information
#
# Table name: company_funds_load_requests
#
#  id                   :integer          not null, primary key
#  company_id           :integer
#  requested_by_user_id :integer          not null
#  reference_id         :string(255)      not null
#  date                 :date             not null
#  amount_id            :integer
#  remark               :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class CompanyFundsLoadRequest < ActiveRecord::Base
  belongs_to :company
  belongs_to :requested_by_user, class_name: 'User'
  belongs_to :amount

  validates :company, presence: true
  validates :requested_by_user, presence: true
  validates :reference_id, presence: true
  validates :date, presence: true
  validates :amount, presence: true

  accepts_nested_attributes_for :amount

  delegate :amount_value, to: :amount
  delegate :requested_by_user_name, to: :requested_by_user

  scope :with_amount, -> {joins(:amount).select('expenses.*, amount.*')}
end
