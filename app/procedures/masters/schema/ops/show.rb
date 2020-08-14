class Masters::Schema::Ops::Show < Masters::Schema::Ops::Base

  step FindMasterSchema()
  step Policy::Pundit(Masters::Schema::Policy, :show?)

  def find_model(context, params:, current_user:, **)
    context[:model] = MasterSchema.find_by(company_id: current_user.company_id, master_key: params[:id])
  end

end