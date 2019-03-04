# == Schema Information
#
# Table name: bank_accounts
#
#  id                 :integer          not null, primary key
#  yes_bank_vendor_id :integer
#  account_number     :string(255)
#  ifsc               :string(255)
#  name               :string(255)
#  address_1          :string(255)
#  address_2          :string(255)
#  address_3          :string(255)
#  pin_code           :string(255)
#  country            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_owner_id   :integer
#  account_owner_type :string(255)
#  company_id         :integer
#  reimbursable       :boolean
#  default_account    :boolean          default(FALSE)
#  is_deleted         :boolean          default(FALSE)
#  disabled           :boolean          default(FALSE)
#  deleted_at         :datetime
#  on_hold            :boolean          default(FALSE)
#

class BankAccount < ApplicationRecord
  include Accountable
  include SoftDeletable

  belongs_to :account_owner, optional: true, polymorphic: true

  has_many :receiving_payments, as: :receiving_account
  has_many :finly_transactions, as: :finly_account

  validates :account_number, presence: true #, format: Constants::VALID_BANK_ACCOUNT
  validates :ifsc, presence: true, format: Constants::VALID_IFSC
  validates :name, presence: true
  validate :valid_bank_account

  accepts_nested_attributes_for :account_owner

  default_scope {order(created_at: :desc)}

  scope :with_account_owner, -> (user_ids, vendor_ids) {
    where('(account_owner_type = ? AND account_owner_id IN (?)) OR (account_owner_type - ? AND account_owner_id IN (?)', "User", user_ids, "YesBankVendor", vendor_ids)
  }
  scope :with_id, -> (id) {where id: id}
  scope :only_vendors, -> {where account_owner_type: "YesBankVendor"}
  scope :only_users, -> {where account_owner_type: "User"}
  scope :default_accounts, -> { where(default_account: true).non_deleted}
  scope :non_deleted, -> {where deleted_at: nil}
  scope :with_owner_id, -> (owner_id) {
    where account_owner_id: owner_id
  }
  scope :with_company, -> (company_id) {
    where company_id: company_id
  }

  scope :with_account_number, -> (account_number) {
    where account_number: account_number
  }

  scope :with_owner_ids, -> (type, ids) {
    case type
      when 1, '1'
        where(account_owner_type: "User").where(id: ids)
      when 2, '2'
        where(account_owner_type: "YesBankVendor").where(id: ids)
    end
  }

  scope :filter_owner_type, -> (owner_type) {
    if owner_type == '1'
      where account_owner_type: "User"
    elsif owner_type == '2'
      where account_owner_type: "YesBankVendor"
    else
      # do nothing?
    end
  }

  scope :beneficiary_type, -> (owner_type) {
    if owner_type == '1'
      where account_owner_type: "User"
    elsif owner_type == '2'
      where account_owner_type: "YesBankVendor"
    else
      # do nothing?
    end
  }

  scope :filter_search, -> (term) {
    # todo - dirty code, see if this can be improved
    ids = self.where('name like ? OR account_number like ? OR ifsc like ?', "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)
    user_ids = User.where('first_name like ? OR last_name like ?', "%#{term}%", "%#{term}%").pluck(:id)
    vendor_ids = YesBankVendor.where('name like ?', "%#{term}%").pluck(:id)
    ids += BankAccount.where('(account_owner_type = ? AND account_owner_id IN (?)) OR (account_owner_type = ? AND account_owner_id IN (?))', "User", user_ids, "YesBankVendor", vendor_ids)
    where(id: ids)
  }

  before_save do
    self.ifsc = self.ifsc.match(Constants::VALID_IFSC).to_s
    self.account_number = self.account_number&.strip
  end

  after_create do
    if self.account_owner.is_a?(Company)
      self.update(company_id: self.account_owner_id)
    else
      self.update(company_id: self.account_owner.company_id)
    end
  end

  def as_json(options={})
    {
        id: id,
        account_number: account_number,
        ifsc: ifsc,
        name: name,
        default_account: default_account
    }
  end

  private

  def valid_bank_account
    pattern = Regexp.new(Constants::VALID_BANK_ACCOUNT)
    return if self.persisted?
    unless self.account_number =~ pattern && !self.persisted?
      errors.add(:account_number, "is not valid")
      return false
    end
  end

end
