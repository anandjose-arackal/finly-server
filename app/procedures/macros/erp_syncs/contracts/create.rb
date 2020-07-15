class Macros::ErpSyncs::Contracts::Create < Reform::Form

  property :current_user, virtual: true
  property :company
  property :status_id, deserializer: -> (input, represented, **) {
    represented.status_id = ErpSyncStatus.id_for(input[:status])
  }
  property :macro, deserializer: -> (input, represented, **) {
    represented.macro = Macro.find_by(company_id: represented.current_user.company&.id, macro_id: input[:macro_id])
  }
  property :reference_id
  property :message
  property :attempted_at, deserializer: -> (input, represented, **) {
    represented.attempted_at = input[:attempted_at] || DateTime.now
  }
  property :record

  validates :macro, presence: true
  validates :company, presence: true
  validates :record, presence: true
  validates :status_id, presence: true
end