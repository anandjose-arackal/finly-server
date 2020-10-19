module PolicyIndex
  extend ActiveSupport::Concern

  def searchkick_data
    {
        name: name
    }
  end

  # index Indexes::Vp do
  #
  #   document_type :policies
  #   permissions [:admin]
  #   category :masters
  #   route 'policies/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:policy_name],
  #           fixed_right: []
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         policy_id: [record.id],
  #         policy_name: [record.name],
  #     }
  #   end
  # end
end