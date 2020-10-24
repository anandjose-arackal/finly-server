class DepartmentIndex <  Searchkick::Api::DSL

  record_type 'departments'
  field :department_name, value: -> (record) { record.full_name }
  field :department_code, value: -> (record) { record.department_code }

  # def searchkick_data
  #   {
  #       department_name: full_name,
  #       department_code: department_code,
  #   }
  # end

  # index Indexes::Vp do
  #   document_type :departments
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
  #         sequence_id: record.department_code,
  #         gl_code: record.gl_code
  #     }
  #   end
  # end

end