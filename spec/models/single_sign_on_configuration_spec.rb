# == Schema Information
#
# Table name: single_sign_on_configurations
#
#  id                                 :bigint           not null, primary key
#  company_id                         :integer
#  assertion_consumer_service_url     :string(255)
#  assertion_consumer_service_binding :string(255)
#  name_identifier_format             :string(255)
#  issuer                             :string(255)
#  idp_sso_target_url                 :string(255)
#  idp_cert_fingerprint               :string(255)
#  idp_cert                           :string(255)
#  idp_cert_fingerprint_algorithm     :string(255)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  single_sign_on_type_id             :integer
#  authentication_context             :string(255)
#  finly_sso_path                     :string(255)
#  label                              :string(255)
#  uuid                               :string(36)
#

require 'rails_helper'

RSpec.describe SingleSignOnConfiguration, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
