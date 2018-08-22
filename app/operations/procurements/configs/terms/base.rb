class Procurements::Configs::Terms::Base < Procurements::Configs::Base
  def procurement_term_parameters
    params.require(:procurement_term).permit(:id, :name, :description)
  end
end