    # t.string "name"
    # t.datetime "deleted_at"
    # t.datetime "created_at", precision: 6, null: false
    # t.datetime "updated_at", precision: 6, null: false


class EmailApprovalStatus < NonTenantedApplicationRecord
  include Seedable

  def self.values
    [:pending, :approved, :rejected, :retracted]
  end

  def self.id_for(key)
    self.where(name: key)&.first&.id
  end
end
