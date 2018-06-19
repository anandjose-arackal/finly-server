class DeliveryChallan < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :procurement
  belongs_to :location
  belongs_to :payment_term
  belongs_to :procurement_term
  belongs_to :document_status
end
