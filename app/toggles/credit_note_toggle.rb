class CreditNoteToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/credit_note#forms_enabled', false
  end

  def bulk_import_enabled?
    feature_flag 'release/credit_note#bulk_import_enabled', false
  end
end
