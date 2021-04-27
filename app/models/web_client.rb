# == Schema Information
#
# Table name: web_clients
#
#  id         :bigint           not null, primary key
#  version    :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WebClient < NonTenantedApplicationRecord

  default_scope {order(updated_at: :desc)}

end
