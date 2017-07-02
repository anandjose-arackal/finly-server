class Orders::OrderCards::Base < BaseOperation
  attr_accessor :params

  # def self.call(user, params)
  #   self.new(user,params).run
  # end

  # def initialize(user, params)
  #   super(user, params)
  # end

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    # if config.blank?
    #   add_message :error, 'Error loading configuration'
    # end
  end

  # def subscription
  #   config_for :subscription
  # end

  # def card_program_id
  #   config_for :card_program_id
  # end

  # def payment_type_id
  #   config_for :payment_type_id
  # end

  # def payment_order_type_id
  #   config_for :payment_order_type_id
  # end

  # def config_for(key)
  #   if config.present?
  #     return config[key]
  #   end
  #   nil
  # end

  def order_cards_params

    return {} unless params.present?

    order_type_ids = []

    if params[:order_type_ids].present?
      # If being sent as an array of ids
      if params[:order_type_ids].is_a?(Array) && params[:order_type_ids][0].present?
        order_type_ids += params[:order_type_ids]
      end

      # If being sent as comma separated string
      if params[:order_type_ids].is_a?(String)
        order_type_ids += params[:order_type_ids].split(',')
      end
    end

    p = params.permit(:view) 
    p[:order_type_ids] = order_type_ids
    p.permit!

  end

end