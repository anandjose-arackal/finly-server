class Admin::CompanyGroups::Contract < Reform::Form

  property :name, validates: {presence: true}

end