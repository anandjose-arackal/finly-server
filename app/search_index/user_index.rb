class UserIndex < SearchIndex::Model

  index Indexes::Vp do
    include_associations(:profile)

    document_type :users
    permissions [:admin]
    category :masters
    route 'users/{{record_id}}/params={}'
    layout(
        {
            fixed_left: [:user_name, :user_email],
            fixed_right: [:status_name]
        }
    )

    serialize do |record|
      {
          user_name: record.name,
          user_email: record.email,
          employee_id: record.profile&.employee_id,
          status_name: record.status&.titleize
      }
    end

  end
end