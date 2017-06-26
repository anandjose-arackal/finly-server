module ApplicationHelper

  ALERT_TYPES = ['success', 'error', 'information', 'alert', 'warning'] unless const_defined?(:ALERT_TYPES)


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
    if view == 'admin' || view == :admin
      return true
    end
    false
  end

  def is_finance_view
    view = params[:view]
    if view == 'finance' or view == 'finance_manager'
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

  def parse_params
    filter_values = (@filter or {})
    param = []
    return param if params.blank?
    params.each do |key, value|
      hash={}
      filter = []
      if !key.start_with?('filter_') || value.blank?
        next
      else
        s_key = key[7..key.length]
        name = key[7].upcase + key[8..key.length]
        case s_key
          when 'user_id'
            hash = {name: 'User', value: filter_values[:user_name]}
          when 'manager_id'
            hash = {name: 'Manager', value: filter_values[:manager_name]}
          when 'status'
            hash= {name: 'Status', value: filter_values[:status]}
          when 'category_id'
            hash = {name: 'Category', value: filter_values[:category]}
          when 'amount'
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
          when 'receipt'
            hash = {name: name, value: 'No Receipt'} if value != 'nil'
          else
            if value.is_a?(Hash)
              param_val = ""
              value.each do |k, v|
                next if v.blank? || k.blank?
                param_val += ", " unless param_val.blank?
                param_val+= "#{k[0].upcase + k[1..k.length]} - #{v[0].upcase + v[1..v.length]}"
                h = {}
                h["#{key}[#{k}]"] = v
                filter << h
              end
              next if param_val.blank?
              if param_val.include?('Sort_by -')
                param_val.sub!('Sort_by -', 'By')
              end
              hash = {name: name, value: param_val}
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
    end
    param
  end

  # type is 1 for expense, 2 for report
  def get_old_filters(old_params, type=1)
    param = []
    old_params.each do |key, value|
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

  def snap_flash(options = {})
    flash_messages = []
    flash.each do |type, message|
      next if message.blank?

      type = get_type(type)

      next unless ALERT_TYPES.include?(type)
      Array(message).each do |msg|
        flash_messages << "noty({text: #{msg}, type: #{type}});" if msg
      end
    end
    javascript_tag flash_messages.join("\n").html_safe
  end

  def snap_flash_without(options = {})
    flash_messages = []
    flash.each do |type, message|
      next if message.blank?

      type = get_type(type)

      next unless ALERT_TYPES.include?(type)
      Array(message).each do |msg|
        message = msg
        formatting = {type: "#{type}", duration: '7000'}
        type = "#{type.to_s}"
        flash_messages << {text: message, format: formatting, type: type}
      end
    end
    flash_messages
  end

  def load_yaml

  end

  def color_for(item)
    Constants::FLASH_COLORS[item.to_sym] rescue 'red'
  end

  def notification_container_for(item)
    color = color_for(item)
    if color == 'red'
      return 'ohsnap-priority'
    end
    return 'ohsnap'
  end

  private
  def get_type(type)
    type = 'information' if type == 'info' or type == 'notice'
    type = 'error' if type == 'failure' or type == 'danger'
    type
    # type = type.to_sym
    # type = :blue if type == :info
    # type = :green if type == :notice or type == :success
    # type = :orange if type == :alert
    # type = :red if type == :error or type == :failure or type == :danger
    # type
  end

  def full_title(page_title = '')
    base_title = 'Finly'
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

end
