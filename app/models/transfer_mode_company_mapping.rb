class TransferModeCompanyMapping < ApplicationRecord
	belongs_to :company
	belongs_to :transfer_mode, class_name: 'TransferMode', foreign_key: :mode_id

	alias_method :mode, :transfer_mode
	alias_method :payment_mode, :transfer_mode
	
	scope :with_id, -> (ids) {
    where(id: ids)
  }

	scope :filter_mode, -> (company_id) {
		where company_id: company_id
	}

	def self.fetch_names
		all.map(&:transfer_mode).map(&:name)
	end

	def self.fetch_ids
		all.map(&:mode_id)
	end

	def self.fetch_modes
		all.map {|tm| [tm.transfer_mode.name, tm.id]}.to_h
	end

	def as_json
		{
			id: id,
			name: mode.name,
			mode_id: mode.mode_id
		}
	end

end
