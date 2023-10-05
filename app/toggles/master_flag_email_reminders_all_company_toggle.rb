class MasterFlagEmailRemindersAllCompanyToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/master_flag_email_reminders_all_company', true
  end
end
