class Admin::Masters::Macros::Contracts::Macro < Reform::Form

  property :macro_id, validates: {presence: true, format: {with: /\A\w+\z/}}, deserializer: -> (input, represented, **) {
    represented.macro_id ||= input[:macro_id]
  }
  property :name, validates: {presence: true}
  property :description
  property :script, validates: {presence: true}
  property :macro_type_id, validates: {presence: true}
  property :active, deserializer: -> (input, represented, **) {
    represented.active ||= (input[:active].nil? ? true : input[:active])
  }
  property :start_date
  property :end_date
  property :long_running_job, deserializer: -> (input, represented, **) {
    represented.long_running_job ||= (input[:long_running_job].nil? ? false : input[:long_running_job])
  }
  property :company_id, presence: true
  property :user_id, presence: true, deserializer: -> (input, represented, **) {
    user_id = input[:user_id]
    user = User.where(company_id: input[:company_id]).where('id = ? or email = ?', user_id, user_id).first
    represented.user_id ||= user&.id if user.present?
  }
  collection :schedules, populate_if_empty: MacroSchedule, form: Admin::Masters::Macros::Contracts::Schedule

end