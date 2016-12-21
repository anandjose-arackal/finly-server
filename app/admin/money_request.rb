ActiveAdmin.register MoneyRequest do

  filter :user_id, as: :select, collection: proc {User.all}
  filter :status_id, as: :select, collection: proc {MoneyRequestStatus.all}
  filter :payment_mode_id, as: :select, collection: proc {PaymentMode.all}

  index do
    id_column
    column :name
    column :submitted_at
    column "Advance Request Status", :status_name
    column :controlling_user
    column :user
    column :memo
    column :payment_mode_name
    column :required_by_date
    column :loaded_at
    column :created_at
    column :updated_at
    column :accounted
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
