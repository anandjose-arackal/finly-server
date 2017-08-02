class Benefits::TaxBenefits::Base < BaseOperation
  attr_accessor :config

  def self.call(config, user, params)
    self.new(config, user,params).run
  end

  def initialize(config, user, params)
    super(user, params)
    self.config = config
  end

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if config.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def subscription
    config_for :subscription
  end

  def card_program_id
    config_for :card_program_id
  end

  def payment_type_id
    config_for :payment_type_id
  end

  def payment_purpose_id
    config_for :payment_purpose_id
  end

  def config_for(key)
    if config.present?
      return config[key]
    end
    nil
  end

end