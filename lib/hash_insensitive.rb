require 'active_support/hash_with_indifferent_access'

class HashInsensitive < HashWithIndifferentAccess
  def [](key)
    super(_insensitive(key))
  end

  def []=(key, value)
    super _insensitive(key), value
  end

  # Keeping it DRY.
  protected

  def _insensitive(key)
    key.respond_to?(:downcase) ? key.downcase : key
  end
end