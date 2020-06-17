class Masters::Users::Profile::Ops::Update < Transactions::API

  step Model(UserProfile, :find_by_user_id)
  step Policy::Pundit(Masters::Users::Profile::Policy, :update?)
  step Contract::Build(constant: Masters::Users::Profile::Contracts::Update)
  step Contract::Validate()
  step Contract::Persist()

end