class BbpsBiller < ApplicationRecord
  serialize :biller_payment_modes, JSON
  serialize :biller_payment_channels, JSON
  serialize :biller_customer_params, JSON
  serialize :biller_response_params, JSON
  serialize :biller_additional_info, JSON
  serialize :interchange_fee_conf, JSON
  serialize :interchange_fee, JSON
end
