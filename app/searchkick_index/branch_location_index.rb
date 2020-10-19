module BranchLocationIndex
  extend ActiveSupport::Concern

  included do
    searchkick_record_type :locations
  end

  def searchkick_data
    {
        name: name,
        location_code: location_code
    }
  end

  # index Indexes::Vp do
  #
  #   document_type :locations
  #   permissions [:admin]
  #   category :masters
  #   route 'organization_account/params={"id":"settings"}'
  #   layout(
  #       {
  #           fixed_left: [:description, :sequence_id],
  #           fixed_right: []
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         description: record.name,
  #         sequence_id: record.location_code,
  #         gl_code: record.gl_code
  #     }
  #   end
  # end
end