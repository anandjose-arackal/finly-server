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
#  deleted_at                         :datetime
#  sso_type                           :string(255)      default("")
#  logo                               :string(255)      default("")
#

class SingleSignOnConfiguration < ApplicationRecord
  belongs_to :company
  belongs_to :single_sign_on_type

  def self.as_json(options = {})
    super(options)
  end

  scope :with_single_sign_on_type, -> (type_id) {
    where single_sign_on_type_id: type_id
  }

  scope :with_id, -> (id) {
    where id: id
  }

  def as_json(options={})
    {
      id: id,
      label: label,
      finly_sso_path: finly_sso_path,
      logo: logo,
      sso_type: sso_type
    }
  end

end
