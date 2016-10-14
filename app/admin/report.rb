ActiveAdmin.register Report do

  filter :user_id, as: :select, collection: proc {User.all}
  filter :report_status_id, as: :select, collection: proc {ReportStatus.all}
  filter :policy_id, as: :select, collection: proc {Policy.all}

  index do
    id_column
    column :name
    column :submitted_at
    column "Report Status", :status_name
    column :controlling_user
    column :user
    column :memo
    column :policy
    column :created_at
    column :updated_at
    column :accounted
    column :archived
    column :is_deleted
  end

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
