class Email < ApplicationRecord
  serialize :recipient, JSON

  belongs_to :entity, polymorphic: true, optional: true
  # belongs_to :user
  belongs_to :company, optional: true

  has_many :events, class_name: "EmailEvent"

  scope :order_created_at, -> (type) {reorder created_at: (type.to_sym || :desc)}
end
