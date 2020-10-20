class Events::Serializer

  def self.encode(object)
    if object.is_a?(ActiveRecord::Base)
      serialize_record(object)
    elsif object.is_a?(ActiveRecord::Relation)
      serialize_record(object, relation: true)
    elsif [Hash,
           ActionController::Parameters,
           ActiveSupport::HashWithIndifferentAccess].include?(object.class)
      object.each {|key, value| object[key] = encode(value)}
    elsif object.class == Array
      object.each_with_index {|item, index| object[index] = encode(item)}
    elsif object.class == Class
      object.to_s
    else
      object
    end
  end

  def self.decode(data)
    case data.class.name
    when Hash.name, ActionController::Parameters.name, ActiveSupport::HashWithIndifferentAccess.name
      if access(data, :serialized) and access(data, :object)
        deserialize_record data
      else
        data.each {|k, v| data[k] = decode v}
      end
    when Array.name
      data.each_with_index do |item, index|
        data[index] = decode item
      end
    else
      data
    end
  end

  private

  def self.deserialize_record(data)
    decrypted_data = decrypt(access(data, :object))
    record_type = access(decrypted_data, :record_type)
    record_id = access(decrypted_data, :record_id)
    relation = access(decrypted_data, :relation)

    record = Object.const_get(record_type)
    unless record
      raise "#{record_type} could not be instantiated"
    end

    if record_id.blank?
      return (relation ? record.none : nil)
    end
    ActsAsTenant.without_tenant do
      if relation
        record.unscoped.where id: record_id
      else
        record.unscoped.find_by id: record_id
      end
    end
  end

  def self.serialize_record(object, relation: false)
    {
        serialized: true,
        object: encrypt(
            {
                record_type: object.class.to_s,
                record_id: object.id,
                relation: relation
            }
        )
    }
  end

  def self.access(hash, value)
    hash[value.to_s] || hash[value.to_s.to_sym]
  end

  def self.crypt
    ActiveSupport::MessageEncryptor.new("452ef9875305903bfb52d1f401219b2a")
  end

  def self.decrypt(data)
    crypt.decrypt_and_verify(data)
  end

  def self.encrypt(data)
    crypt.encrypt_and_sign(data)
  end

end