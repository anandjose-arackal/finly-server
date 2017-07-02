class AddPointOfContactForAllCompanies < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      user = company.users.first
      if user.present?
        user.update(point_of_contact: true)
      end
    end
  end
end
