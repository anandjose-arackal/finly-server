module YesBankVendorIndex
  extend ActiveSupport::Concern

  included do
    scope :searchkick_import, -> {
      includes(:policy, :status, :gstin_locations, :created_by)
    }

    searchkick_record_type :vendors
  end

  def searchkick_data
    {
        vendor_name: business_name,
        vendor_trade_name: trade_name,
        policy_id: policy_id,
        policy_name: policy&.name,
        status_id: status_id,
        status_name: status&.name&.titleize,
        vendor_id: vendor_id,
        description: description,
        tax_id: pan,
        tax_registration_number: gstin_locations.pluck(:gstin).join(", "),
    }
  end

  # index Indexes::Vp do
  #   include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS, :gstin_locations, :created_by
  #
  #   document_type :vendors
  #   permissions Masters::Vendors::Index.permissions
  #   category :masters
  #   route 'vendor/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:vendor_name, :sequence_id],
  #           fixed_right: [:created_by_name, :created_by_email, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         vendor_name: record.business_name,
  #         vendor_trade_name: record.trade_name,
  #         policy_id: record.policy_id,
  #         policy_name: record.policy&.name,
  #         status_id: record.status_id,
  #         status_name: record.status&.name&.titleize,
  #         sequence_id: record.vendor_id,
  #         description: record.description,
  #         tax_id: record.pan,
  #         tax_registration_number: record.gstin_locations.pluck(:gstin).join(", "),
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end