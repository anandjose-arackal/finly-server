ActiveAdmin.register User do

  filter :first_name_or_last_name_or_maiden_name_cont, as: :string, label: "Name"
  filter :company_id, as: :select, collection: proc {Company.all}
  filter :email, as: :string
  filter :updated_at, as: :date_range

  scope :pending
  scope :signed_up
  scope :active
  scope ("Inactive") do |scope|
    scope.where(active: false)
  end


  index do
    id_column
    column :name
    column :email
    column :mobile_number
    column :company
    column :last_sign_in_at
    column :last_sign_in_ip
    column :active

    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs :first_name
    f.inputs :last_name
    f.inputs :email
    f.inputs :password
    f.inputs :password_confirmation
    f.inputs :mobile_number
    f.inputs :active
    f.inputs "COmpany ID", :company_id
    f.inputs "User Roles" do
      f.has_many :role_mapping do |role_mapping|
        role_mapping.input :user_role_id, as: :select, :label => "Select Roles", collection: UserRole.all
      end
    end
    f.inputs "Team Mapping" do
      f.has_many :team_mapping do |team_mapping|
        team_mapping.input :manager_id, as: :select, label: "Select Manager", collection: User.all
        team_mapping.input :finance_manager_id, as: :select, label: "Select Finance Manager", collection: User.all
        team_mapping.input :default
      end
    end

    f.actions
  end

  permit_params :first_name, :last_name, :email, :mobile_number, :active, :password, :password_confirmation, :company_id, role_mapping_attributes: [:user_role_id],
                                                                              team_mapping_attributes: [:manager_id, :finance_manager_id, :default]
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end
