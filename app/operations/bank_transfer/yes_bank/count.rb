class BankTransfer::YesBank::Count < BankTransfer::YesBank::Base
  attr_accessor :payment_orders_count, :role_id

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
    params[:with_application] = RequestStore.store[:current_app].to_s
    params[:filter_vendor_payments] = '1'
  end

  def process
    case role_id
      when UserRole.id_for(:admin)
        self.payment_orders_count = user.company.payment_orders.count
      when UserRole.id_for(:manager)
        # insert logic for getting payment orders from a particular manager team
      when UserRole.id_for(:finance_manager)
        # insert logic for getting payment orders from a particular finance manager team
      else
        # i.e. personal view
        self.payment_orders_count = user.payment_orders.count
    end
  end

  def success
    payment_orders_count
  end
end


