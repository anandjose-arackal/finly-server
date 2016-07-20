module ApplicationHelper

  def ej(obj)
    escape_javascript obj.to_s
  end

  def is_personal_view
    unless is_admin_view or is_finance_view or is_manager_view
      return true
    end
    false
  end

  def is_admin_view
    view = params[:view]
    if view == 'admin'
      return true
    end
    false
  end

  def is_finance_view
    view = params[:view]
    if view == 'finance'
      return true
    end
    false
  end

  def is_manager_view
    view = params[:view]
    if view == 'manager'
      return true
    end
    false
  end

  def load_params(p={})
    return p if params.blank?
    p = {} if p.blank?
    p[:view] = params[:view] if p[:view].blank? and params[:view].present?
    p
  end

  # type is 1 for expense, 2 for report
  def get_old_filters(old_params, type=1)
    param = []
    old_params.each do |key, value|
      hash = {}
      filter = []
      if !key.start_with?('filter_') || value.blank?
        next
      else
        name = key[7].upcase + key[8..key.length]
        if name == 'User_id'
          k = name[0..name.length - 4]
          v = @filter_user_name
          hash = {name: k, value: v}
        elsif name == 'Manager_id'
          k = name[0..name.length - 4]
          v = @filter_manager_name
          hash = {name: k, value: v}
        elsif name == 'Status'
          status = Expense.statuses.key(value.to_i) if type == 1
          status = Report.statuses.key(value.to_i) if type == 2
          status = value.gsub("_", " ") if current_page?(user_settlement_list_path)
          status = status[0].upcase + status[1..status.length]
          hash= {name: name, value: status}
        elsif name == 'Category_id'
          hash = {name: 'Category', value: @categories.find_by(id: value).name}
        elsif name == 'Amount'
          type = value[:type]
          amount = value[:value]
          next if type.blank? || amount.blank?
          case type
            when 'lteq', 'lt'
              type = "Less Than"
            when 'eq'
              type = "Equal To"
            when 'gteq', 'gt'
              type = "Greater Than"
          end
          hash = {name: name, value: "#{type} \u20B9#{amount}"}
          filter << {'filter_amount[type]': value[:type], 'filter_amount[value]': amount}
        elsif value.is_a?(Hash)
          param_val = ""
          value.each do |k, v|
            next if v.blank? || k.blank?
            param_val += ", " unless param_val.blank?
            param_val+= "#{k[0].upcase + k[1..k.length]} - #{v[0].upcase + v[1..v.length]}"
            h = {}
            h["#{key}[#{k}]"] = v
            filter<<h
          end
          next if param_val.blank?
          if param_val.include?('Sort_by -')
            param_val.sub!('Sort_by -', 'By')
          end
          hash = {name: name, value: param_val}
        elsif name == 'Receipt' && value == 'nil'
          hash = {name: name, value: 'No Receipt'}
        else
          hash = {name: name, value: value}
        end
      end
      unless hash.blank?
        if filter.blank?
          h = {}
          h[key] = value
          filter = [h]
        end
        hash[:filter] = filter
        param << hash
      end
    end
    param
  end

  def param
    return ''

  end

end
