# == Schema Information
#
# Table name: bbps_billers
#
#  id                             :bigint           not null, primary key
#  biller_id                      :string(255)
#  biller_name                    :string(255)
#  biller_alias_name              :string(255)
#  biller_category_name           :string(255)
#  biller_mode                    :string(255)
#  biller_accepts_adhoc           :boolean
#  parent_biller                  :boolean
#  parent_biller_id               :string(255)
#  biller_owner_shp               :string(255)
#  biller_coverage                :string(255)
#  fetch_requirement              :string(255)
#  payment_amount_exactness       :string(255)
#  support_bill_validation        :string(255)
#  biller_effctv_from             :date
#  biller_effctv_to               :date
#  biller_temp_deactivation_start :date
#  biller_temp_deactivation_end   :date
#  biller_payment_modes           :text(4294967295)
#  biller_payment_channels        :text(4294967295)
#  biller_customer_params         :text(4294967295)
#  biller_response_params         :text(4294967295)
#  biller_additional_info         :text(4294967295)
#  interchange_fee_conf           :text(4294967295)
#  interchange_fee                :text(4294967295)
#  status                         :string(255)
#  biller_description             :text(65535)
#  support_deemed                 :string(255)
#  support_pending_status         :string(255)
#  biller_time_out                :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

require 'rails_helper'

RSpec.describe BbpsBiller, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
