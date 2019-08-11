class Admin::Implementations::ImportTemplate < Admin::Implementations::RequestHandler

  def process
    self.response = self.master.new(user, params).template
  end

end