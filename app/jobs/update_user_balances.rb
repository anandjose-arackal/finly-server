# job that cycles through all users and sets the balances for all of them
class UpdateUserBalances < ActiveJob::Base

  def perform
    User.all.each do |user|
      date = DateUtils.yesterday_local_date
      User::Balances::SetBalances(user, {date: date})
    end
  end

end
