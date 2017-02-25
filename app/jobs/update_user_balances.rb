class UpdateUserBalances < ActiveJob::Base

  def perform
    User.all.each do |user|
      date = Date.yesterday_local_date
      User::Balances::SetBalances(user, {date: date})
    end
  end

end
