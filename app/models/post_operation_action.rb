class PostOperationAction < ActiveRecord::Base

  serialize :payload

  belongs_to :post_operatable, polymorphic: true

  validates :post_operatable_id, presence: true
  validates :post_operatable_type, presence: true
  validates :operation, presence: true

end
