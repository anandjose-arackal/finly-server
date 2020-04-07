class IndexBuilder::ContentTypes::User < IndexBuilder::ContentTypes::Base

  register :user

  attribute :value

  def format_value(context, user, record, exposure, data)
    return nil unless data[:value].present?
    user = data[:value]
    data[:value] = {
        id: user.id,
        name: user.name,
        email: user.email,
        mobile_number: user.mobile_number
    }
    data
  end

end