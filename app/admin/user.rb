ActiveAdmin.register User do

  filter :first_name_or_last_name_or_maiden_name_cont, as: :string, label: "Name"

  index do
    id_column
    column :name
    column :email
    column :mobile_number
  end

  form do |f|
    f.inputs :first_name
    f.inputs :last_name
    f.inputs :email
    f.inputs :mobile_number
    f.inputs :company_id
    f.inputs "User Roles" do
      f.has_many :role_mapping do |role_mapping|
        role_mapping.input :user_role_id, as: :select, :label => "Select Roles", collection: UserRole.all
      end
    end
    f.inputs "Team Mapping" do
      f.has_many :team_mapping do |team_mapping|
        team_mapping.input :manager_id, as: :select, label: "Select Manager", collection: User.all
        team_mapping.input :finance_manager_id, as: :select, label: "Select Finance Manager", collection: User.all
      end
    end

    f.actions
  end

  permit_params :first_name, :last_name, :email, :mobile_number, :company_id, role_mapping_attributes: [:user_role_id],
                                                                              team_mapping_attributes: [:manager_id, :finance_manager_id]
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
