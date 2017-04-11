class Benefits::TaxBenefits::Meal::Create < Benefits::TaxBenefits::Meal::Base
  attr_accessor :order_data, :processed_order_data, :payment_order, :payment_order_type_id, :scheduled_at

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading request'
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
    self.order_data = params[:payment_order]
    self.payment_order_type_id = params[:payment_order_type_id]
    self.processed_order_data = Benefits::TaxBenefits::Process.(user, payment_order: self.order_data)
    if params[:scheduled_at].present?
      self.scheduled_at = Date.parse params[:scheduled_at]
    end
  end

  def validate
    if  scheduled_at && scheduled_at < Date.today
      add_message :error, 'Scheduled Date cannot be less than the current date'
      return
    end

    if payment_order_type_id.blank? or self.processed_order_data.blank?
      add_message :error, 'Error loading configuration. Please try again'
      return
    end

    if self.processed_order_data.failure?
      add_message :error, self.processed_order_data.messages[:error]
      return
    end

    unless self.processed_order_data.payment_order_valid
      add_message :error, 'Please fix the issues before confirming the request'
    end
  end

  def process
    amount_requested = Amount.new(value: self.order_data.requested_amount, currency_id: 1)
    payment_order_params = {
        payment_order_type_id: self.payment_order_type_id,
        scheduled_at: self.scheduled_at,
        processed_at: DateTime.now,
        initiating_user: user,
        payment_order_status_id: PaymentOrderStatus.id_for(:scheduled),
        company_id: user.company_id,
        amount_requested: amount_requested
    }
    self.payment_order = user.payment_orders.build payment_order_params
    unless self.payment_order.valid?
      add_message :error, self.payment_order.errors.full_messages
      return
    end

  end

  # def init
  #   self.order_data = params[:order]
  #   self.validate_only = params[:validate_only]
  #   self.errors = []
  # end
  #
  # def validate
  #   if order_data.blank?
  #     add_message :error, 'Error loading order details'
  #     return
  #   end
  #
  #   company_balance = Company::VirtualAccount::Balance.(user.company).balance rescue 0
  #
  #   self.requested_amount = 0
  #   parsed_data.each do |item|
  #     self.requested_amount += item[:amount].to_d rescue 0
  #   end
  #
  #   if self.requested_amount > company_balance
  #     self.errors << 'Insufficient funds to initiate the transfer'
  #   end
  #
  #   validate_order
  # end
  #
  # def process
  #   processed_amount = 0
  #   amount_requested = Amount.create value: requested_amount, currency_id: 1
  #   amount_processed = Amount.create value: processed_amount, currency_id: 1
  #   self.payment_order = user.company.build payment_order_type_id: PaymentOrderType.id_for(:meal_card),
  #                                           scheduled_at: Date.today,
  #                                           processed_at: DateTime.now,
  #                                           initiating_user: user,
  #                                           payment_order_status: PaymentOrderStatus.id_for(:in_progress),
  #                                           note: params[:note],
  #                                           amount_requested: amount_requested,
  #                                           amount_processed: amount_processed,
  #                                           payment_file: file
  #
  #   # headers = [:user, :amount, :status, :message]
  #   parsed_data.each do |item|
  #     response = item.dup
  #     user_email_mob = item[:user]
  #     user = self.user.company.users.find_for_database_authentication(email: user_email_mob)
  #     amount = item[:amount].to_d rescue nil
  #
  #     # Check if user was found
  #     if user.blank?
  #       status = 'Failed'
  #       message = 'User not found'
  #       response << {user: user_email_mob, amount: amount, status: status, message: message}
  #       next
  #     end
  #
  #     # Check if the amount is valid
  #     if amount.blank?
  #       status = 'Failed'
  #       message = 'Invalid amount'
  #       response << [user_email_mob, amount, status, message]
  #       next
  #     end
  #
  #     # Check if user has a Meal Card
  #     card = user.cards.with_card_program(CardProgram.id_for(:meal)).first rescue nil
  #     if card.blank?
  #       status = 'Failed'
  #       message = 'Card not found'
  #       response << [user_email_mob, amount, status, message]
  #       next
  #     end
  #
  #     unless validate_only
  #       # Credit the funds to the card
  #       resp = ItzCash::Credit.(user, card: card, amount: amount)
  #       if response.success?
  #         status = 'Success'
  #         response << [user_email_mob, amount, status]
  #       else
  #         status = 'Failed'
  #         message = resp.messages[:error].first
  #         response << [user_email_mob, amount, status, message]
  #       end
  #     end
  #   end
  # end
  #
  # def validate_order
  #   processed_amount = 0
  #   amount_requested = Amount.create value: requested_amount, currency_id: 1
  #   amount_processed = Amount.create value: processed_amount, currency_id: 1
  #   self.payment_order = user.company.build payment_order_type_id: PaymentOrderType.id_for(:meal_card),
  #                                           scheduled_at: Date.today,
  #                                           processed_at: DateTime.now,
  #                                           initiating_user: user,
  #                                           payment_order_status: PaymentOrderStatus.id_for(:in_progress),
  #                                           note: params[:note],
  #                                           amount_requested: amount_requested,
  #                                           amount_processed: amount_processed,
  #                                           payment_file: file
  #
  #   # headers = [:user, :amount, :status, :message]
  #   parsed_data.each do |item|
  #     response = item.dup
  #     user_email_mob = item[:user]
  #     user = self.user.company.users.find_for_database_authentication(email: user_email_mob)
  #     amount = item[:amount].to_d rescue nil
  #
  #     # Check if user was found
  #     if user.blank?
  #       status = 'Failed'
  #       message = 'User not found'
  #       response << {user: user_email_mob, amount: amount, status: status, message: message}
  #       next
  #     end
  #
  #     # Check if the amount is valid
  #     if amount.blank?
  #       status = 'Failed'
  #       message = 'Invalid amount'
  #       response << [user_email_mob, amount, status, message]
  #       next
  #     end
  #
  #     # Check if user has a Meal Card
  #     card = user.cards.with_card_program(CardProgram.id_for(:meal)).first rescue nil
  #     if card.blank?
  #       status = 'Failed'
  #       message = 'Card not found'
  #       response << [user_email_mob, amount, status, message]
  #       next
  #     end
  #
  #     unless validate_only
  #       # Credit the funds to the card
  #       resp = ItzCash::Credit.(user, card: card, amount: amount)
  #       if response.success?
  #         status = 'Success'
  #         response << [user_email_mob, amount, status]
  #       else
  #         status = 'Failed'
  #         message = resp.messages[:error].first
  #         response << [user_email_mob, amount, status, message]
  #       end
  #     end
  #   end
  # end

end