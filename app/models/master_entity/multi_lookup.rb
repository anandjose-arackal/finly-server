class MasterEntity::MultiLookup < MasterEntity
  register :multi_lookup
  database_type :multi_lookup
  set :hint, 'Select values'
  operators :eq_any #, :blank, :present

  option :route

  # schema_contract do
  #   validate :entity_key_format

  #   def entity_key_format
  #     unless self.entity_key&.end_with?('_id')
  #       errors.add :entity_key, 'has to end with _id'
  #     end
  #   end
  # end

  def route
    choices_scope&.route
  end

  def lookup_master_key
    @master_key ||= route&.split(".")&.last
  end

  def lookup_master_schema
    return nil if lookup_master_key.blank?

    company.master_schemas.find_by(master_key: lookup_master_key)
  end

  # Strips the _id from the record keys
  # def association_name
  #   if entity_key.end_with?('_id')
  #     entity_key[0..(entity_key.length - 4)]
  #   else
  #     entity_key
  #   end
  # end
end
