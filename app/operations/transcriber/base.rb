class Transcriber::Base < Admin::Base

  def pre_validate
    # todo - ultimate jugaad, will be changed once login and permissions are integrtaed
    authorized_company_ids = [(Company.find_by(name: "Transcriber").id rescue 0),
                              (Company.find_by(name: "Jouska").id rescue 0),
                              1]
    unless authorized_company_ids.include?(user.company_id)
      add_message :error, "You are not authorized to perform this action"
    end
  end
end
