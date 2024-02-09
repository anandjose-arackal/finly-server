class Procurements::Configs::Terms::Destroy < Procurements::Configs::Terms::Base
  attr_accessor :procurement_term

  def init
    op = Procurements::Configs::Terms::Index.(user, params)
    self.procurement_term = op.terms.find_by id: params[:id]
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    unless self.procurement_term.present?
      add_message :error, 'Unable to find procurement term'
    end
  end

  def process
    
    if self.procurement_term.destroy
      add_message :success, 'Successfully Deleted Procurement Term'
    else
      add_message :error, "Couldn't Delete Procurement Term"
    end
  end
end