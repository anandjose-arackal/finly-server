class Admin::Masters::Macros::Jobs::Resolver < Resolver::API

  entity MacroJob

  def load(params)
    return Macro.none unless params[:macro_id]

    MacroJob.where(macro_id: params[:macro_id])
  end

end