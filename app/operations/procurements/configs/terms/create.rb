class Procurements::Configs::Terms::Create < Procurements::Configs::Terms::Base
  attr_accessor :procurement_term, :procurement_term_params, :default_term

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def init
    self.procurement_term_params = procurement_term_parameters
    self.default_term = Procurements::Configs::Terms::Index.(user, params).terms.with_default.first rescue nil

  end

  def process
    
    self.procurement_term = user.company.procurement_terms.new(procurement_term_params)

    if self.procurement_term.valid?
      if ([true, "on", "true", 1, "1"].include? procurement_term_params[:default]) && default_term.present?
        self.default_term.update(default: false)
      end
      self.procurement_term.save
      add_message :success, 'Successfully Created Procurement Term'
    else
      add_message :error, self.procurement_term.errors.full_messages
    end
  end
end