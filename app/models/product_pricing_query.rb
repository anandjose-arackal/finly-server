# == Schema Information
#
# Table name: product_pricing_queries
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  mobile_number        :string(255)
#  email                :string(255)
#  employees            :string(255)
#  accounting_system    :string(255)
#  monthly_transactions :string(255)
#  monthly_invoices     :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  product              :string(255)
#  prepaid_cards        :string(255)
#

class ProductPricingQuery < ApplicationRecord
end
