module CostCenterIndex
  extend ActiveSupport::Concern

  def searchkick_data
    {
        name: full_name,
        cost_center_code: cost_center_code
    }
  end

  # index Indexes::Vp do
  #
  #   document_type :cost_centers
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
  #         description: record.full_name,
  #         sequence_id: record.cost_center_code,
  #         gl_code: record.gl_code
  #     }
  #   end
  # end

end