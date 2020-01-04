class ExportManager::Master::Users::VendorPayments::Index < ExportManager::Builders::Spreadsheet


  label 'Export'
  description 'Users Export'
  configurable true
  system :vp
  screen 'users.vp.index'
  handle :vp_users
  validate :input

  attribute :employee_id
  attribute :name
  attribute :email
  attribute :mobile_number
  attribute :status

  def input
    result = ::BankTransfer::Users::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    users = result.users.includes(:profile)
    users
  end


  def employee_id(user)
    user.profile&.employee_id.to_s
  end

  def name(user)
    user.name
  end

  def email(user)
    user.email
  end

  def mobile_number(user)
    user.mobile_number
  end

  def status(user)
    user.active
  end


end