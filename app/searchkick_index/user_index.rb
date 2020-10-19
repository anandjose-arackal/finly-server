module UserIndex
  extend ActiveSupport::Concern

  included do
    scope :searchkick_import, -> {
      includes(:profile)
    }
  end

  def searchkick_data
    {
        user_name: name,
        user_email: email,
        employee_id: profile&.employee_id,
        status_name: status&.titleize
    }
  end

  # index Indexes::Vp do
  #   include_associations(:profile)
  #
  #   document_type :users
  #   permissions [:admin]
  #   category :masters
  #   route 'users/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:user_name, :user_email],
  #           fixed_right: [:status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         user_name: record.name,
  #         user_email: record.email,
  #         employee_id: record.profile&.employee_id,
  #         status_name: record.status&.titleize
  #     }
  #   end
  #
  # end
end