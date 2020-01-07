# == Schema Information
#
# Table name: artifacts
#
#  id                      :bigint           not null, primary key
#  resource_id             :integer
#  resource_type           :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer
#  attachment_content_type :string(255)
#  attachment_updated_at   :datetime
#  description             :text(65535)
#  company_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  creator_id              :integer
#

