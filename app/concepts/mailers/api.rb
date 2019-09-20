class Mailers::API

  def self.document(document = NoObject)
    @document = document unless document == NoObject
    @document
  end

  def receive(user, message)

  end

end