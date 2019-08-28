class Admin::Implementations::ImportTemplate < Admin::Implementations::RequestHandler

  def process
    self.response = self.master.(user, params)
  end

end