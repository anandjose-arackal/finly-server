class BranchLocationIndex <  Searchkick::Api::DSL

  record_type 'locations'
  field :location_name, value: -> (record) { record.name }
  field :location_code, value: -> (record) { record.location_code }

  # included do
  #   searchkick_record_type :locations
  # end
  #
  # def searchkick_data
  #   {
  #       location_name: name,
  #       location_code: location_code
  #   }
  # end

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