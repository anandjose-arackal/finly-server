module CategoryIndex
  extend ActiveSupport::Concern

  def searchkick_data
    {
        name: name,
        sequence_id: category_code,
    }
  end

  # index Indexes::Vp do
  #
  #   document_type :categories
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
  #         sequence_id: record.category_code,
  #         category_name: [record.name],
  #         category_code: [record.category_code],
  #         gl_code: record.gl_code
  #     }
  #   end
  #
  # end
end