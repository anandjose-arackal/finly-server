class Admin::Masters::Macros::Resolver < Resolver::API

  entity Macro

  def load(params)
    return Macro.none unless params[:company_id]

    Macro.where(company_id: params[:company_id])
  end

end