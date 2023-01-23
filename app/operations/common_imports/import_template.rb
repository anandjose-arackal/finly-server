class CommonImports::ImportTemplate < CommonImports::RequestHandler

  def process
    self.response = self.master.(user, params)
  end

end