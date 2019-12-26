class ExportManager::Master::Users::VendorPayments::Index < ExportManager::Master::BaseSubscriber

  bus ExportManager::Master::BaseMaster
  subscribe :vp_users
  generator ExportManager::Generator::Spreadsheet
  processor ExportManager::Processor::Asynchronous
  validate :input

  attribute :employee_id
  attribute :name
  attribute :email
  attribute :mobile_number
  attribute :status

  def name
    'Users'
  end

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