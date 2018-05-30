class Procurements::Configs::Terms::Update < Procurements::Configs::Terms::Base
  attr_accessor :procurement_term, :procurement_term_params
  def init
    self.procurement_term_params = procurement_term_parameters
    self.procurement_term = user.company.procurement_terms.find_by id: params[:id]
  end

  def validate
    unless self.procurement_term.present?
      add_message :error, 'Procurement Term not found'
    end
  end

  def process
    self.procurement_term.assign_attributes(procurement_term_params)
    if self.procurement_term.valid?
      self.procurement_term.save
      add_message :success, 'Successfully Updated Procurement Term'
    else
      add_message :error, self.procurement_term.errors.full_messages
    end
  end

end