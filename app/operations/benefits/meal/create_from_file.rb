class Benefits::Meal::CreateFromFile < Benefits::Meal::Base
  attr_accessor :file, :parsed_data

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate the transfer'
      return
    end
    if user.valid_password?
      add_message :error, 'Invalid Password'
    end
  end

  def init
    self.file = params[:file]
    self.parsed_data = ImportUtil.load_spreadsheet(file, [:user, :amount])
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Error loading configuration file'
      return
    end

    company_balance = Company::VirtualAccount::Balance.(user.company).balance rescue 0

    requested_amount = 0
    parsed_data.each do |item|
      requested_amount += item[:amount].to_d rescue 0
    end

    if requested_amount > company_balance
      add_message :error, 'Insufficient funds to initiate the transfer'
    end
  end

  def process
    # headers = [:user, :amount, :status, :message]
    response = []
    response_header = ['User Email / Mobile Number', 'Amount', 'Status', 'Message']
    response << response_header
    parsed_data.each do |item|
      response = item.dup
      user_email_mob = item[:user]
      user = self.user.company.users.find_for_database_authentication(email: user_email_mob)
      amount = item[:amount].to_d rescue nil

      # Check if user was found
      if user.blank?
        status = 'Failed'
        message = 'User not found'
        response << [user_email_mob, amount, status, message]
        next
      end

      # Check if the amount is valid
      if amount.blank?
        status = 'Failed'
        message = 'Invalid amount'
        response << [user_email_mob, amount, status, message]
        next
      end

      # Check if user has a Meal Card
      card = user.cards.with_card_program(CardProgram.id_for(:meal)).first rescue nil
      if card.blank?
        status = 'failed'
        message = 'Card not found'
        response << [user_email_mob, amount, status, message]
        next
      end

      # Credit the funds to the card
      resp = ItzCash::Credit.(user, card: card, amount: amount)
      if response.success?
        status = 'Success'
        response << [user_email_mob, amount, status]
      else
        status = 'Failed'
        message = resp.messages[:error].first
        response << [user_email_mob, amount, status, message]
      end
    end
  end

end