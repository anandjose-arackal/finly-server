class Card::Export::Transaction::AsCsv < Card::Export::Transaction::Base
  attr_accessor :atm_withdrawals, :result, :file_name

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if params[:view].blank?
      add_message :error, "You are not allowed to do this."
    end
  end

  def init
    view = params[:view]
    user_ids = []
    
    case view
    when 'manager', 'finance_manager'
      user_ids = User::Team::Index.(f, view: view).pluck(:id)
    when 'admin'
      user_ids = user.company.users.pluck(:id)
    end

    self.atm_withdrawals = CardTransaction.atm_withdrawals.with_user user_ids
  end

  def validate
  end

  def process
    column_names = ['ATM Terminal', 'Amount', 'Transaction Time', 'Serial ID', 'User Name', 'Mobile Number']
    self.result = CSV.generate do |csv|
      csv << column_names
      atm_withdrawals.each do |atm_withdrawal|
        csv << retrieve_data(column_names, atm_withdrawal)
      end
    end
  end

  def post_process
    # todo add time stamp to file name
    self.file_name = 'export'
  end

  def success
    Card::Export::Base::ExportPresenter.new(user, {data: result, file_name: file_name}, messages)
  end



  # a = 
  # for atm - transsaction amount
  # for others - billing amount
end