# == Schema Information
#
# Table name: money_request_items
#
#  id               :integer          not null, primary key
#  money_request_id :integer          not null
#  category_id      :integer          not null
#  amount_id        :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#


class MoneyRequestItem < ActiveRecord::Base
  belongs_to :category
  belongs_to :amount
  belongs_to :money_request
  belongs_to :money_request_item_category

  scope :with_id, -> (id) {where id: id}
  scope :with_amount, -> {joins :amount}
  scope :sum_amount, -> {with_amount.sum(:INR)}
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
