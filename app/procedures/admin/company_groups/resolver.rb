class Admin::CompanyGroups::Resolver < Resolver::API

  def load(params)
    CompanyGroup.all
  end

end