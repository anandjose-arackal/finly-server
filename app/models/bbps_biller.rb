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
#  deleted_at                     :datetime
#  disabled                       :boolean          default(FALSE)
#

class BbpsBiller < ApplicationRecord
  serialize :biller_payment_modes, JSON
  serialize :biller_payment_channels, JSON
  serialize :biller_customer_params, JSON
  serialize :biller_response_params, JSON
  serialize :biller_additional_info, JSON
  serialize :interchange_fee_conf, JSON
  serialize :interchange_fee, JSON

  scope :filter_search, -> (term) {
    where("biller_name like ? or biller_alias_name like ?", "%#{term}%", "%#{term}%")
  }

  scope :filter_category_name, -> (name){
    where(biller_category_name: name)
  }

  # defining a few methods for consistency here
  def name
    self.biller_name
  end

  def account_number
    ""
  end

  def account_owner
    self.biller_name
  end

  def ifsc
    ""
  end

  def as_json(options={})
    if options[:autocomplete]
      data = {
          label: biller_name,
          value: id
      }

      return data
    elsif options[:index]
      data = {
          id: id,
          biller_id: biller_id,
          biller_name: biller_name,
          biller_alias_name: biller_alias_name,
          biller_category_name: biller_category_name,
      }
      return data
    end
    {
      biller_id: biller_id,
      biller_name: biller_name,
      biller_alias_name: biller_alias_name,
      biller_category_name: biller_category_name,
      biller_mode: biller_mode,
      biller_accepts_adhoc: biller_accepts_adhoc,
      parent_biller: parent_biller,
      parent_biller_id: parent_biller_id,
      biller_owner_shp: biller_owner_shp,
      biller_coverage: biller_coverage,
      fetch_requirement: fetch_requirement,
      payment_amount_exactness: payment_amount_exactness,
      support_bill_validation: support_bill_validation,
      biller_effctv_from: biller_effctv_from,
      biller_effctv_to: biller_effctv_to,
      biller_temp_deactivation_start: biller_temp_deactivation_start,
      biller_temp_deactivation_end: biller_temp_deactivation_end,
      biller_payment_modes: biller_payment_modes,
      biller_payment_channels: biller_payment_channels,
      biller_customer_params: biller_customer_params,
      biller_response_params: biller_response_params,
      biller_additional_info: biller_additional_info,
      interchange_fee_conf: interchange_fee_conf,
      interchange_fee: interchange_fee,
      status: status,
      biller_description: biller_description,
      support_deemed: support_deemed,
      support_pending_status: support_pending_status,
      biller_time_out: biller_time_out,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  def as_json_autocomplete(options={})
    {
        label: biller_name,
        value: id
    }
  end
end
