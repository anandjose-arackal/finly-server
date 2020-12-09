class Docs::P2P::CreditNotes::Action < ActionManager::API

  action :macro,
         :jobs,
         policy: Macros::Jobs::Policy,
         authorize: :create?,
         route: 'credit_notes.index',
         label: "Jobs",
         icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png"

end