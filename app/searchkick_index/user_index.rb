class UserIndex < Searchkick::Api::DSL

  scope do
    includes(:profile)
  end

  record_type 'users'

  field :user_name, value: -> (record) { record.name }
  field :user_email, value: -> (record) { record.email }
  field :employee_id, value: -> (record) { record.profile&.employee_id }
  field :status_name, value: -> (record) { record.status&.titleize }

  # included do
  #   scope :searchkick_import, -> {
  #     includes(:profile)
  #   }
  # end
  #
  # def searchkick_data
  #   {
  #       user_name: name,
  #       user_email: email,
  #       employee_id: profile&.employee_id,
  #       status_name: status&.titleize
  #   }
  # end

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