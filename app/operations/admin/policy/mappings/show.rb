class Admin::Policy::Mappings::Show <  Policy::Mappings::Show
  def user_model
    AdminUser
  end

  def init
    params[:purpose_id] = MappingPurpose.id_for(:expense_management)
    super
  end
end