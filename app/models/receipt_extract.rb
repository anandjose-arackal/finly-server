class ReceiptExtract < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :amount
  belongs_to :receipt_extract_source
  belongs_to :sourcable, polymorphic: true

  validates :receipt_extract_sources_id, presence: true
  validates :receipt_id, presence: true
end
