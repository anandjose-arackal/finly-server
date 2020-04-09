class IndexBuilder::ContentTypes::User < IndexBuilder::ContentTypes::Base

  register :user

  attribute :value

  def format_value(context, user, record, exposure, data)
    return data unless data[:value].present?

    user = data[:value]
    data[:value] = user.name
    data[:id] = user.id
    data[:name] = user.name
    data[:email] = user.email
    data[:mobile_number] = user.mobile_number
    data
  end

end