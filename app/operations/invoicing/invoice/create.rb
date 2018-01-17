class Invoicing::Invoice::Create < Invoicing::Invoice::Base

  attr_accessor :invoice_params, :invoice

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init

  end

  def validate

  end

  def process

  end


end