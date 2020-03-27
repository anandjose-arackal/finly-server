json.data do
  json.company do
    json.name current_company.name
    json.id current_company.id
    json.logo do
      if current_company.configuration.logo.present?
        json.url current_company.configuration.logo.url(:thumb)
      end
    end
  end
  json.user do
    json.name current_user.name
    json.initials current_user.initials
    json.id current_user.id
    json.email current_user.email
    json.mobile_number current_user.mobile_number
  end
  json.menu @op[:menu]
  json.modules @op[:modules]
end