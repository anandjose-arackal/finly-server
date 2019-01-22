class ResizeExternalAdditionalInformationInCompanyTags < ActiveRecord::Migration[4.2]
  def change
    change_column :company_tags, :external_additional_information, :text, limit: 16.megabytes - 1
  end
end
