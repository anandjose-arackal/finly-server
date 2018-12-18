# == Schema Information
#
# Table name: money_request_items
#
#  id                             :integer          not null, primary key
#  money_request_id               :integer          not null
#  category_id                    :integer
#  amount_id                      :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  money_request_item_category_id :integer
#

class MoneyRequestItem < ActiveRecord::Base
  belongs_to :category
  belongs_to :amount
  belongs_to :money_request
  belongs_to :money_request_item_category

  scope :with_id, -> (id) {where id: id}
  scope :with_amount, -> {joins :amount}
  scope :sum_amount, -> (currency_code=:INR) {with_amount.sum(currency_code)}
  scope :active_categories, -> do

  end
  scope :with_category, ->(category_id) {where money_request_item_category_id: category_id}
  scope :with_money_request_item_category, ->(category_id) {where money_request_item_category_id: category_id}
  scope :with_money_request, ->(id) {where money_request_id: id}

  delegate :amount_value, to: :amount
  delegate :category_name, to: :category

  accepts_nested_attributes_for :amount

  before_save :handle_category_mapping

  validates :money_request_item_category_id, presence: true
  # validates :money_request, presence: true

  def amount
    s = super
    return nil if s.nil?
    return s if money_request.nil?
    if money_request and money_request.payment_mode_id == PaymentMode.id_for(:cash) and money_request.destination_pocket.present?
      s.currency = money_request.destination_pocket.base_currency
    end
    s
  end

  def handle_category_mapping
    if self.category_id.present? and self.money_request_item_category_id.blank?
      self.money_request_item_category_id = self.category_id
      self.category_id = nil
    end
  end

  def category
    self.money_request_item_category
  end

  def category_id
    self.money_request_item_category_id
  end

end
