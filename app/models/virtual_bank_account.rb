# == Schema Information
#
# Table name: virtual_bank_accounts
#
#  id                 :integer          not null, primary key
#  account_number     :string(255)
#  ifsc               :string(255)
#  description        :text(65535)
#  parent_id          :integer
#  parent_type        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  expires_by         :date
#  purpose_id         :integer
#  company_id         :integer
#  active             :boolean          default(TRUE)
#  is_deleted         :boolean          default(FALSE)
#  initiating_user_id :integer
#

# parent here will be either the payment receivable, or user, or whatever
class VirtualBankAccount < ActiveRecord::Base
  include SoftDeletable
  
  belongs_to :parent, polymorphic: true
  belongs_to :purpose, class_name: "VirtualAccountPurpose"
  belongs_to :company
  belongs_to :initiating_user, class_name: "User"

  validates :purpose, presence: true

  scope :cash_on_hand_returns, -> { where purpose_id: VirtualAccountPurpose.id_for(:cash_on_hand_return) }
  scope :payment_receivables, -> { where purpose_id: VirtualAccountPurpose.id_for(:payment_receivable) }
  scope :virtual_bank_accounts, -> { where purpose_id: VirtualAccountPurpose.id_for(:virtual_bank_account) }
  scope :invoices, -> { where purpose_id: VirtualAccountPurpose.id_for(:invoice) }

  def deactivate
    self.update(active: false)
  end

  def reactivate
    self.update(active: true)
  end

end
