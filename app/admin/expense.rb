ActiveAdmin.register Expense do

  filter :expense_type_id, as: :select, collection: proc {ExpenseType.all}
  filter :expense_status_id, as: :select, collection: proc {ExpenseStatus.all}
  filter :user_id, as: :select, collection: proc {User.all}
  filter :date

  index do
    id_column
    column :user
    column :expense_status_name
    column :report_name
    column :expense_type_name
  end

  permit_params :user_id, :date, :expense_status_id, :expense_type_id, :category_id, :note, amount_attributes: [:value, :currency_id]

  # filter :company, as: :select, collection: proc {Company.all}
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

  # # experimenting with AR scopes
  # config.filters = false

  # sidebar :filters, only: :index do
  #   render 'admin/expense/filters'
  # end

  # controller do

  #   # Overrides the Ransack search methods and uses default AR scopes
  #   def apply_filtering(chain)
  #     Expense.active_admin_scopes.each do |scope|
  #       puts "scope: #{scope} params: #{filter_params[scope]}"
  #       chain = chain.filter_by(scope, filter_params[scope]) unless filter_params[scope].blank?
  #     end
  #     chain
  #   end

  #   def filter_params
  #     @filter_params = params[:admin_expenses] || {}
  #   end

  # end


end
