class CreditNoteToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/credit_note#forms_enabled', false
  end
end
