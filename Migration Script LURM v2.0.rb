
def set_chain(reviewal_mapping_data, policy, user, purpose, threshold = 0)
	default_reviewal_mapping = policy.user_team_mapping.with_user(user.id).where(purpose_id: purpose, default: true).first
	non_default_reviewer_mapping = policy.user_team_mapping.with_user(user.id).where(purpose_id: purpose, default: false).where.not(greater_than_amount_id: nil).first


	if non_default_reviewer_mapping.present?		
		approves_to = non_default_reviewer_mapping.approves_to
		if approves_to.present?
			app_threshold = non_default_reviewer_mapping.greater_than_amount.value

			# clone the mapping so far to a new one with the threshold
			if reviewal_mapping_data[app_threshold].blank?
				reviewal_mapping_data[app_threshold] = []
				reviewal_mapping_data[app_threshold] += reviewal_mapping_data[threshold]
			end
			reviewal_mapping_data[app_threshold].push(approves_to.id) unless reviewal_mapping_data[app_threshold].include?(approves_to.id)
			if user.id != non_default_reviewer_mapping.approves_to.id
				set_chain(reviewal_mapping_data, policy, approves_to, purpose, app_threshold)
			end
		end
	end


	if default_reviewal_mapping.present?
		approves_to = default_reviewal_mapping.approves_to
		if default_reviewal_mapping.approves_to.present?

		  if reviewal_mapping_data[threshold].present? && !reviewal_mapping_data[threshold].include?(approves_to.id)
		  	reviewal_mapping_data[threshold].push(approves_to.id)
		  end

		  if user.id != default_reviewal_mapping.approves_to.id
		    set_chain(reviewal_mapping_data, policy, default_reviewal_mapping.approves_to, purpose, threshold)
		  end
		end
	end
end


def set_chain_finance(reviewal_mapping_data, policy, user, purpose, threshold = 0)
	default_reviewal_mapping = policy.user_team_mapping.with_user(user.id).where(purpose_id: purpose, default: true).first
	non_default_reviewer_mapping = policy.user_team_mapping.with_user(user.id).where(purpose_id: purpose, default: false).where.not(greater_than_amount_id: nil).first
	

	if non_default_reviewer_mapping.present?		
		approves_finance_to = non_default_reviewer_mapping.approves_finance_to
		if approves_finance_to.present?
			app_threshold = non_default_reviewer_mapping.greater_than_amount.value

			# clone the mapping so far to a new one with the threshold
			if reviewal_mapping_data[app_threshold].blank?
				reviewal_mapping_data[app_threshold] = []
				reviewal_mapping_data[app_threshold] += reviewal_mapping_data[threshold]
			end
			reviewal_mapping_data[app_threshold].push(approves_finance_to.id) unless reviewal_mapping_data[app_threshold].include?(approves_finance_to.id)
			if user.id != non_default_reviewer_mapping.approves_finance_to.id
				set_chain_finance(reviewal_mapping_data, policy, approves_finance_to, purpose, app_threshold)
			end
		end
	end


	
	if default_reviewal_mapping.present?
		approves_finance_to = default_reviewal_mapping.approves_finance_to
		if default_reviewal_mapping.approves_finance_to.present?
		  
		  if reviewal_mapping_data[threshold].present? && !reviewal_mapping_data[threshold].include?(approves_finance_to.id)
		  	reviewal_mapping_data[threshold].push(approves_finance_to.id)
		  end	

		  if user.id != default_reviewal_mapping.approves_finance_to.id
		    set_chain_finance(reviewal_mapping_data, policy, default_reviewal_mapping.approves_finance_to, purpose, threshold)
		  end
		end
	end
end


# policies = Policy.where(id: (460..464).to_a)
policies = Policy.all

policies.each do |policy|
	if policy.default
		purposes = [1, 2]
  elsif policy.application == "em"
		purposes = [1]
	elsif policy.application == "vp"
		purposes = [2]
  else
    purposes = []
	end

  purposes.each do |purpose|
		policy.users.each do |user|
			# this array will contain the list of reviewers (in order) for a paricular user inside a policy
			mapping_levels = {}
			mapping_levels[0] = []

			# first setting the managers for this particular user along with their respective approves to
			# reviewal_mapping = policy.user_team_mapping.with_user(user.id).where(purpose_id: 1).first
			reviewal_mapping = policy.user_team_mapping.with_user(user.id).where(purpose_id: purpose).first
			non_default_reviewal_mapping = policy.user_team_mapping.with_user(user.id).where(purpose_id: purpose, default: false).first
			if reviewal_mapping&.default?
				manager = reviewal_mapping.manager
				if reviewal_mapping.present? && manager.present?
					mapping_levels[0] << manager.id
				end
				set_chain(mapping_levels, policy, manager, purpose, 0) if manager.present?
			end
			if non_default_reviewal_mapping.present?
				manager = non_default_reviewal_mapping.manager
				threshold = non_default_reviewal_mapping.greater_than_amount.value
				if manager.present?
					mapping_levels[threshold] = [] unless mapping_levels[threshold].present?
					mapping_levels[threshold] << manager.id
				end
				set_chain(mapping_levels, policy, manager, purpose, threshold) if manager.present?
			end

			# now finding the finance managers for this user along with their approves finance to
			finance_manager = reviewal_mapping&.finance_manager
			if finance_manager.present?
				# add this user as the finance manager for all levels
				mapping_levels.each do |thresh, app_levels|
					app_levels << finance_manager.id unless app_levels.include?(finance_manager.id)
				end
			end
			if reviewal_mapping&.default? && finance_manager.present?
				set_chain_finance(mapping_levels, policy, finance_manager, purpose, 0)
			end
			if non_default_reviewal_mapping.present?
				finance_manager = non_default_reviewal_mapping.finance_manager
				threshold = non_default_reviewal_mapping.greater_than_amount.value
				mapping_levels[threshold] = [] if mapping_levels[threshold].blank?

				if finance_manager.present?
					mapping_levels[threshold].push(finance_manager.id) unless mapping_levels[threshold].include?(finance_manager.id)
					set_chain_finance(mapping_levels, policy, finance_manager, purpose, threshold)
				end
			end

			finance_manager = reviewal_mapping&.finance_manager
			puts mapping_levels


			# now mapping_levels will have an array of all the reviewers for a particular user
			# so we can create the LURM for these users within the policy.
			# Although the LRM is still a question
			mapping_levels.each do |threshold, reviewers|
				reviewers.each_with_index do |reviewer, index|
          # based on the purpose, the different levels can be created
          if purpose == 1
            ["ReportProvider", "MoneyRequestProvider"].each do |provider|
              level = policy.levels.find_by(level_number: (index + 1), associated_entity_type: provider)
              level = policy.levels.build(name: "Level #{index +1}", level_number: (index + 1), associated_entity_type: provider) if level.blank?
              level.save

              reviewer_user = User.find_by id: reviewer
              unless reviewer_user&.manager?
                reviewer_user.role_mapping.build(user_role_id: UserRole.id_for(:manager), purpose_id: purpose).save
              end

              next if level&.level_user_reviewer_mappings&.where(user_id: user.id)&.pluck(:reviewer_id)&.include?(reviewer)
              level.level_user_reviewer_mappings.build(user_id: user.id, reviewer_id: reviewer, policy_id: policy.id, threshold: threshold).save
            end
          else
            level = policy.levels.find_by(level_number: (index + 1), associated_entity_type: "BankPaymentRequestProvider")
            level = policy.levels.build(name: "Level #{index +1}", level_number: (index + 1), associated_entity_type: "BankPaymentRequestProvider") if level.blank?
            level.save

            reviewer_user = User.find_by id: reviewer
            unless reviewer_user&.vendor_payments_reviewer?
              reviewer_user.role_mapping.build(user_role_id: UserRole.id_for(:reviewer), purpose_id: purpose).save
            end

            next if level&.level_user_reviewer_mappings&.where(user_id: user.id)&.pluck(:reviewer_id)&.include?(reviewer)
            level.level_user_reviewer_mappings.build(user_id: user.id, reviewer_id: reviewer, policy_id: policy.id, threshold: threshold).save
          end
			  end
      end
      # now creating finance managers and creditors for this particular policy - using PURs
      next if finance_manager.blank?
      if purpose == 1
        next if policy.policy_user_roles.pluck(:user_id).include?(finance_manager.id)
        policy.policy_user_roles.build(user_id: finance_manager.id, user_role_id: UserRole.id_for(:finance_manager)).save
      elsif purpose == 2
        next if policy.policy_user_roles.pluck(:user_id).include?(finance_manager.id)
        policy.policy_user_roles.build(user_id: finance_manager.id, user_role_id: UserRole.id_for(:creditor)).save
      end
    end
	end
end


# now extract all the level user reviewal mapping for a particular 
policies.each do |policy|
  if policy.default
    purposes = [1, 2]
  elsif policy.application == "em"
    purposes = [1]
  elsif policy.application == "vp"
    purposes = [2]
  else
    purposes = []
  end

  purposes.each do |purpose|
    if purpose == 1
      ["ReportProvider", "MoneyRequestProvider"].each do |provider|
        policy.levels.where(associated_entity_type: provider).each do |level|
          lurms = level.level_user_reviewer_mappings
          reviewer_ids = lurms.pluck(:reviewer_id).uniq
          reviewer_ids.each do |reviewer_id|
            next if level.level_reviewer_mappings.pluck(:reviewer_id).include?(reviewer_id)
            threshold = lurms.where(reviewer_id: reviewer_id).first.threshold
            level.level_reviewer_mappings.build(reviewer_id: reviewer_id, threshold: threshold).save
          end
        end
      end
    else
      policy.levels.where(associated_entity_type: "BankPaymentRequestProvider").each do |level|
        lurms = level.level_user_reviewer_mappings
        reviewer_ids = lurms.pluck(:reviewer_id).uniq
        reviewer_ids.each do |reviewer_id|
          next if level.level_reviewer_mappings.pluck(:reviewer_id).include?(reviewer_id)
          threshold = lurms.where(reviewer_id: reviewer_id).first.threshold
          level.level_reviewer_mappings.build(reviewer_id: reviewer_id, threshold: threshold).save
        end
      end
    end
  end
end