class Procurements::Configs::Terms::Update < Procurements::Configs::Terms::Base
  attr_accessor :procurement_term, :procurement_term_params, :procurement_terms, :default_term

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def init
    self.procurement_term_params = procurement_term_parameters
    # self.procurement_term = user.company.procurement_terms.find_by id: params[:id]
    self.procurement_terms = Procurements::Configs::Terms::Index.(user, params).terms
    self.procurement_term = self.procurement_terms.find_by id: params[:id] rescue nil
    self.default_term = procurement_terms.with_default.first rescue nil
  end

  def validate
    unless self.procurement_term.present?
      add_message :error, 'Procurement Term not found'
    end
  end

  def process
    self.procurement_term.assign_attributes(procurement_term_params)
    if self.procurement_term.valid?
      if ([true, "on", "true", 1, "1"].include? procurement_term_params[:default]) && default_term.present?
        self.default_term.update(default: false)
      end
      self.procurement_term.save
      add_message :success, 'Successfully Updated Procurement Term'
    else
      add_message :error, self.procurement_term.errors.full_messages
    end
  end
end