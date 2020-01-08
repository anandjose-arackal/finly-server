class Docs::UtilityBills::Bills::Contracts::OrderNumber < Docs::UtilityBills::Bills::Contracts::Base
  property :id
  property :order_number, validates: {presence: true}
  property :order_number_type, validates: {presence: true}
end