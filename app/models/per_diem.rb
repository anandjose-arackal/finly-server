# == Schema Information
#
# Table name: per_diems
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  rate_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  configurable_id   :integer
#  configurable_type :string(255)
#  is_deleted        :boolean          default(FALSE)
#  deleted_at        :datetime
#

class PerDiem < ApplicationRecord
  include SoftDeletable

  belongs_to :configurable, optional: true, polymorphic: true

  belongs_to :rate, optional: true, class_name: "Amount"

  validates :rate, presence: true
  validates :configurable, presence: true
  validates :name, presence: true

  accepts_nested_attributes_for :rate

  delegate :rate_value, to: :rate

  scope :active, -> {where is_deleted: false}

  scope :with_id, -> (id) {where id: id}
  scope :find_from_id, -> (id) {where(id: id).first}

  def rate
    return nil if super.nil?
    Amount.new(value: super.value, currency: configurable.base_currency)
  end

  def per_diem_name
    self.name
  end
end
