class Integrations::Base < BaseOperation

  attr_accessor :company, :selected_user, :adapter

  def authorized_user_types
    [:company_admin]
  end


end