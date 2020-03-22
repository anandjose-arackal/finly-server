class ChanngeFortnightlyToFortnight < ActiveRecord::Migration[5.2]
  def change
    period = Period.find_by(id: 7)
    period.update(name: "fortnight")
  end
end
