class ItzCash::AccountDetails < ItzCash::Base

  def pre_validate
    # unless user.present?
    #   add_message :error, 'User not found'
    #   return
    # end
    # unless user.cards.present?
    #   add_message :error, 'A card has not been assigned to the user'
    # end
  end

  def base_url
    'http://demo.itzcash.com'
  end

  def path
    'myaccount/servlet/ItzCashAccountDetailsServlet'
  end

  def post_params
    # {serialid: user.cards.first.serial_id, itzmodule: Constants::ItzCash::MODULE}
    { serialid: 'S00017740090', itzmodule: Constants::ItzCash::MODULE }
  end

  def success
    params[:response_code] = parsed_response[1]
    params[:serial_id] = parsed_response[2]
    params[:balance] = parsed_response[3]
    params[:status] = parsed_response[4]
    params[:suspended_status] = parsed_response[5]
    params[:rate_group_id] = parsed_response[6]
    params[:distributor_id] = parsed_response[7]
    params[:charge_code] = parsed_response[8]
    params[:product_code] = parsed_response[9]
    params[:description] = parsed_response[10]
    BaseHandler::BasePresenter::SuccessPresenter.new(self.user, self.params, self.messages)
  end

  class ItzCash::AccountDetails::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :serial_id, :balance, :status, :suspended_status, :rate_group_id,
                  :distributor_id, :charge_code, :product_code, :description

    def init
      self.response_code =params[:response_code]
      self.serial_id = params[:serial_id]
      self.balance = params[:balance]
      self.status = params[:status]
      self.suspended_status = params[:suspended_status]
      self.rate_group_id = params[:rate_group_id]
      self.distributor_id = params[:distributor_id]
      self.charge_code = params[:charge_code]
      self.product_code = params[:product_code]
      self.description = params[:description]
    end

  end

end