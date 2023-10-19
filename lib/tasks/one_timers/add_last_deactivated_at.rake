namespace :one_timers do
  task populate_last_deactivated_and_last_activated_at_with_default_values: :environment do
		User.find_in_batches.with_index do |group, batch|
			puts "Processing group ##{batch}"
			group.each do |user|
				user.update_column :last_activated_at, user.created_at
				user.update_column :last_deactivated_at, user.updated_at if !user.active
			end
		end
  end
end
