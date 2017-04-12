# Process validates the request for payment order wrt tax benefits and generates the respective output to be sent for confirmation or for creating payment order
class Benefits::TaxBenefits::Process < Benefits::TaxBenefits::Base
  attr_accessor :payment_order_data, :processed_order, :requested_amount, :processable_amount,
                :errors, :payment_order_valid

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    self.payment_order_data = params[:payment_order]
    self.errors = []
    self.payment_order_valid = true
    self.requested_amount = 0
    self.processable_amount = 0
    self.processed_order = []
  end

  def validate
    if payment_order_data.blank?
      self.errors << 'Error loading order details'
      return
    end

    company_balance = Company::VirtualAccount::Balance.(user, company).balance rescue 0

    payment_order_data.each do |item|
      self.requested_amount += item[:amount].to_d rescue 0
    end

    if self.requested_amount > company_balance
      self.errors << 'Insufficient funds to initiate the transfer'
      self.payment_order_valid = false
    end

  end

  def process

    if payment_order_data.is_a?(Hash)
      arr = []
      self.payment_order_data.map {|k, v| arr << v }
      self.payment_order_data = arr
    end

    self.payment_order_data.each do |item|
      user_email_mob = item[:user]
      user = self.user.company.users.find_for_database_authentication(email: user_email_mob)
      amount = item[:amount].to_d rescue nil

      valid = true
      messages = []

      # Check if user was found
      if user.blank?
        valid = false
        messages << 'User not found'
      end

      # Check if the amount is valid
      if amount.blank?
        valid = false
        messages << 'Invalid amount'
      end

      # Check if user has a Meal Card
      card = user.cards.with_card_program(card_program_id).first rescue nil
      if card.blank?
        valid = false
        messages << 'Card not found'
      end

      # todo validate card eligibility -> Currently we are not doing this validation

      if valid
        self.processable_amount += amount
      end

      self.payment_order_valid = false unless valid

      self.processed_order << {user: {identifier: user_email_mob, user_details: user}, card: card, amount: amount, valid: valid, messages: messages}
    end
  end

  def success
    params[:payment_order_data] = self.payment_order_data
    params[:processed_order] = self.processed_order
    params[:requested_amount] = self.requested_amount
    params[:processable_amount] = self.processable_amount
    params[:errors] = self.errors
    params[:payment_order_valid] = self.payment_order_valid
    Benefits::TaxBenefits::Process::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Process::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order_data, :processed_order, :requested_amount, :processable_amount, :errors,
                  :payment_order_valid

    def init
      self.payment_order_data = params[:payment_order_data]
      self.processed_order = params[:processed_order]
      self.requested_amount = params[:requested_amount]
      self.processable_amount = params[:processable_amount]
      self.errors = params[:errors]
      self.payment_order_valid = params[:payment_order_valid]
    end

  end

end