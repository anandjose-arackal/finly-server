class RateContracts::RateContractLineItems::Import < RateContracts::RateContractLineItems::Base
  attr_accessor :rate_contract, :file, :sheet, :result_hash, :error_hash

  def init
    self.file = params[:file]
    self.sheet = ImportUtil.open_spreadsheet(self.file)
    self.company = user.company
  end

  def validate
    error_hash = {}
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      row.each.with_index(1) do |column|
        if index == 2
          if !column.present?
            error_hash[i]['location_code'] = 'Location code cannot be blank'
          end
        end

        if index == 4
          if !column.present?
            error_hash[i]['item_code'] = 'Item code cannot be blank'
          end
        end

        if index == 5
          if !column.present?
            error_hash[i]['start_date'] = 'End date cannot be blank'
          end
        end
        if index == 6
          if !column.present?
            error_hash[i]['end_date'] = 'End date cannot be blank'
          end
        end

        if index == 7
          if !column.present?
            error_hash[i]['cost'] = 'Cost cannot be blank'
          end
        end
      end
    end
    self.error_hash = error_hash
  end

  def process
    if error_hash.blank?
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row.each do |column|
          if row[0].blank?
            location_name = BranchLocation.find_by_location_code(row[1]).id
          end

          if row[2].blank?
            item_id = InventoryLineItem.find_by_item_code(row[3]).id
          end

          unless  RateContractLineItem.create(location_name: location_name, location_code: row[i], item_id: item_id, start_date: row[4], end_date: row[5], cost: row[6])
            add_message :error, 'Some error occurred'
            return
          end
        end
      end
    end
  end
  end

  def post_process
    if success?
      add_message :success, 'Upload successful'
    end
  end

  def import_fields
    [:location_code,
      :item_code,
      :start_date,
      :end_date,
      :cost
    ]
  end

end