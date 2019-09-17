class Events::Mailer

  def self.queue(q, opts = {})
    include Events::Consumer unless self.respond_to?(:from_queue)
    from_queue q, opts
  end

  def self.document(document = NoObject)
    @document = document unless document == NoObject
    @document
  end

  def receive(user, message)

  end

end