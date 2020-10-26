class Forms::ChoiceDependencies::Ops::Show < Transactions::API

  step Model(FormChoiceDependency, :find_by_uuid)
  step Policy::Pundit(Forms::ChoiceDependencies::Policy, :show?)

end