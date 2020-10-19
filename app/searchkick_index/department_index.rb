module DepartmentIndex
  extend ActiveSupport::Concern

  included do
    include Searchkick::Api
  end

  def search_data
    {
        record_type: 'departments',
        name: full_name,
        department_code: department_code,
    }
  end

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