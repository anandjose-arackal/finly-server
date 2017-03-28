# == Schema Information
#
# Table name: manual_expenses
#
#  id         :integer          not null, primary key
#  expense_id :integer
#  merchant   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_deleted :boolean          default(FALSE)
#


class ManualExpense < ActiveRecord::Base
  include SoftDeletable

  belongs_to :expense # foreign key expense_id
  has_many :custom_fields, as: :parent
  accepts_nested_attributes_for :custom_fields

  validates :merchant, presence: true

  scope :merchant_like, -> (merchant, expense_ids) do
    where(expense_id: expense_ids).where('lower(merchant) LIKE ?', "%#{merchant.downcase}%").pluck(:merchant)
  end

  def merchant_name
    self.merchant
  end

end
