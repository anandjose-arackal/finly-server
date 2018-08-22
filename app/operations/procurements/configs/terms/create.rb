class Procurements::Configs::Terms::Create < Procurements::Configs::Terms::Base
  attr_accessor :procurement_term, :procurement_term_params
  def init
    self.procurement_term_params = procurement_term_parameters
  end

  def process
    self.procurement_term = user.company.procurement_terms.new(procurement_term_params)

    if self.procurement_term.valid?
      self.procurement_term.save
      add_message :success, 'Successfully Created Procurement Term'
    else
      add_message :error, self.procurement_term.errors.full_messages
    end
  end


end