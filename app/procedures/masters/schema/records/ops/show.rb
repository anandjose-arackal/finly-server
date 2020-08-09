class Masters::Schema::Records::Ops::Show < Masters::Schema::Records::Base

  schema do
    params do
      required(:master_key).filled
    end
  end

  # This is defined in base class
  step RecordModel(:find)
  step Policy::Pundit(Masters::Schema::Records::Policy, :show?)

end