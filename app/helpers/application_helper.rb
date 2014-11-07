module ApplicationHelper
  # change the default link renderer for will_paginate
  # Modified from https://github.com/mislav/will_paginate/wiki/Link-renderer
  def will_paginate(collection_or_options = nil, options = {})
    unless options[:renderer]
      options = options.merge renderer: BootstrapPagination::Rails
    end
    super *[collection_or_options, options].compact
  end

  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end
  def google_analytics_js
    javascript_tag('
  var _gaq = _gaq || [];
  _gaq.push(["_setAccount", "UA-27780597-1"]);
  _gaq.push(["_setDomainName", "quantifiedawesome.com"]);
  _gaq.push(["_trackPageview"]);

    (function() {
    var ga = document.createElement("script"); ga.type = "text/javascript"; ga.async = true;
    ga.src = ("https:" == document.location.protocol ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js";
    var s = document.getElementsByTagName("script")[0]; s.parentNode.insertBefore(ga, s);
     })();')
  end	
  def clothing_thumbnail(clothing, options = {})
    return unless clothing
    title = clothing.name
    if clothing.last_worn then
      title += " - #{clothing.clothing_logs_count} - #{date_ago_future clothing.last_worn}"
    end
    if clothing then
      options[:size] ||= :medium
      if options[:size] == :tiny
        link_to tag(:img, :src => clothing.image.url(:small)), options[:path] ? options[:path] : clothing_path(clothing), :title => title, :class => "clothing_#{clothing.id}"
      else
        link_to tag(:img, :src => clothing.image.url(options[:size])), options[:path] ? options[:path] : clothing_path(clothing), :title => title, :class => "clothing_#{clothing.id}"
      end
    end
  end
  def date_ago_future(d)
    if d then
      if d.midnight >= Time.zone.now.tomorrow.midnight then
        d
      elsif d.midnight >= Time.zone.now.midnight then
        'today'
      else
        pluralize((Time.zone.now.to_date - d.to_date).to_i, "day") + " ago"
      end
    end
  end

  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def conditional_html( lang = "en", &block )
    '<!--[if lt IE 7 ]>              <html lang="#{lang}" class="no-js ie6"> <![endif]-->
    <!--[if IE 7 ]>                 <html lang="#{lang}" class="no-js ie7"> <![endif]-->
    <!--[if IE 8 ]>                 <html lang="#{lang}" class="no-js ie8"> <![endif]-->
    <!--[if IE 9 ]>                 <html lang="#{lang}" class="no-js ie9"> <![endif]-->
    <!--[if (gte IE 9)|!(IE)]><!--> <html lang="#{lang}" class="no-js"> <!--<![endif]-->      '
  end

  def object_labels(o)
    labels = Array.new
    if o.respond_to? :status and o.status
      labels << '<span class="status">' + o.status + '</span>'
    end
    if o.respond_to? :private? and o.private?
      labels << '<span class="private">' + I18n.t('app.general.private') + '</span>'
    end
    labels.join('').html_safe
  end
  def actions(o)
    model_name = o.class.to_s.underscore
    actions = Array.new
    if o.is_a? Memory
      if can? :update, o
        actions << edit_icon(edit_memory_path(o))
        actions << delete_icon(memory_path(o))
      else
        actions << link_to(I18n.t('app.general.view'), memory_path(o))
      end
    elsif o.is_a? RecordCategory
      if can? :manage_account, current_account
        actions << edit_icon(edit_record_category_path(o))
        case o.category_type
        when 'activity'
          actions << link_to(t('record_categories.show.start_activity'), track_time_path(category_id: o.id), method: :post)
        when 'record'
          actions << link_to(t('record_categories.show.record'), track_time_path(category_id: o.id), method: :post)
        end
      end
    elsif o.is_a? Record
      if can? :manage_account, current_account
        actions << edit_icon(o, destination: request.fullpath)
        actions << delete_icon(record_path(o, destination: request.fullpath))
        actions << link_to('Clone', clone_record_path(o, destination: request.fullpath), method: :post)
      end
    elsif o.is_a? Context
      if managing?
        actions << edit_icon(edit_context_path(o))
        actions << link_to('Start', start_context_path(o))
      end
    elsif o.is_a? ReceiptItem or o.is_a? ReceiptItemType or o.is_a? ReceiptItemCategory or o.is_a? Goal
      if managing?
        actions << edit_icon(o, destination: request.fullpath)
        actions << delete_icon(o, destination: request.fullpath)
      end
    end
    actions
  end

  def tags(o)
    o.tag_list.join(', ')
  end

  def action_list(o)
    actions(o).join(' ').html_safe
  end
  def access_collection
    [[I18n.t('app.general.public'), 'public'],
     [I18n.t('app.general.private'), 'private']]
  end

  def title(s)
    content_for(:title) { s }
  end
  def after_title(s = nil)
    if s
      content_for(:after_title) { s }
    else
      content_for(:after_title) { yield }
    end
  end
  def setup_page(active, title = nil, nav_file = 'nav')
    title(title) if title
    if nav_file
      content_for(:nav) { render nav_file, :active => active }
    end
  end

  def active_class(variable, value)
    variable == value ? 'active' : 'inactive'
  end

  def active_menu(crumb)
    active = nil
    if crumb.is_a? Array
      crumb.each do |a|
        if request.fullpath.start_with? a
          active = true
        end
      end
    elsif crumb.is_a? Regexp and crumb.match request.fullpath
      active = true
    elsif crumb.is_a? String and request.fullpath.start_with? crumb
      active = true
    end
    active ? 'active' : 'inactive'
  end

  def duration(seconds, total = 0, display_type = nil)
    display_type ||= (params && params[:display_type]) ? params[:display_type] : 'time'
    if seconds and seconds > 0
      case display_type
      when 'time' 
        "%d" % (seconds.to_f / 1.hour) + (":%02d" % ((seconds.to_f % 1.hour) / 1.minute))
      when 'decimal'
        "%.1f" % ((seconds.to_f / 1.hour).to_f.round(1))
      when 'percentage'
        "%0.1f%%" % (100.0 * seconds / total)
      end
    end
  end

  def record_category_breadcrumbs(category)
    list = [link_to(I18n.t('app.general.home'), record_categories_path)] + category.ancestors.reverse.map{ |c| link_to c.name, c }
    list.join(' &raquo; ').html_safe
  end

  def record_category_full(category)
    return "(deleted?)" unless category
    category.self_and_ancestors.reverse.map{ |c| link_to c.name, c }.join(' &raquo; ').html_safe
  end

  def record_data(data)
    return '' unless data
    if data.length == 1
      content_tag(:strong, data.keys.first.to_s.humanize) + ": " + data.values.first
    elsif data.length > 0
      content_tag(:ul, data.map { |k, v| content_tag(:li, (content_tag(:strong, k.to_s.humanize).html_safe + ": " + (v || '').html_safe).html_safe) }.join.html_safe).html_safe
    else
      ''
    end
  end

  def graph_time_entry(canvas_var, day_offset, row)
    # Turn this into the Javascript call
    # Javascript needs start time, end time, title, color, and duration
    @colors ||= Hash.new
    @colors[row[2].record_category_id] ||= row[2].record_category.get_color
    @colors[row[2].record_category_id] ||= "#ccc"
    unless row[2].color
      row[2].record_category.color = @colors[row[2].record_category_id]
    end
    start_offset = row[0] - row[0].midnight.in_time_zone
    end_offset = row[1] - row[0].midnight.in_time_zone
    ("graphTimeEntry(#{canvas_var}, #{day_offset}, #{start_offset}, #{end_offset}, " +
      "'#{escape_javascript row[0].strftime('%a %Y-%m-%d %-H:%M')} - #{escape_javascript row[1].strftime('%-H:%M')}: " +
      "#{escape_javascript row[2].full_name} (#{escape_javascript(duration(row[1] - row[0]))})', " +
      "'#{escape_javascript row[2].color}', '#{row[2].record_category.full_name.parameterize.underscore}', " +
      "'#{record_path(row[2])}');").html_safe
  end

  def graph_time_total(canvas_var, range, day, category, total)
    # Turn this into the Javascript call
    # Javascript needs start time, end time, title, color, and duration
    @colors ||= Hash.new
    @colors[category.id] ||= category.get_color
    @colors[category.id] ||= '#ccc'
    @totals_so_far ||= Hash.new { |h,k| h[k] = 86400 }
    day_offset = day - range.begin
    unless category.color
      category.color = @colors[category.id]
    end
    start_offset = @totals_so_far[day_offset] - total
    end_offset = @totals_so_far[day_offset] 
    if start_offset < end_offset
      @totals_so_far[day_offset] -= total
      ("graphTimeEntry(#{canvas_var}, #{day_offset}, #{start_offset}, #{end_offset}, " +
        "'#{escape_javascript day.strftime('%a %Y-%m-%d')} #{escape_javascript category.full_name} (#{escape_javascript(duration(total))})', " +
        "'#{escape_javascript category.color}', '#{category.full_name.parameterize.underscore}');").html_safe
    end
  end

  def record_data_input(record, info, index = nil)
    content_tag(:div, :class => 'optional stringish form-group') do
      key = info[:key] || info["key"]
      label = info[:label] || info["label"] || key
      if key
        s = label_tag("data[#{key}]", label, class: 'control-label')
        s += case info[:type]
             when 'text'
               text_area_tag("record[data][#{key}]", record.data ? record.data[key] : nil, autofocus: (index == 0), class: 'form-control')
             else
               text_field_tag("record[data][#{key}]", record.data ? record.data[key] : nil, autofocus: (index == 0), class: 'form-control')
             end
        s
      end
    end
  end

  def download_as_spreadsheet
    content_tag(:div, link_to(t('general.download_as_spreadsheet'), params.merge(:format => :csv)), :class => 'spreadsheet')
  end

  def feedback_link(text = 'send feedback')
    link_to text, feedback_path(:old_params => params.inspect, :destination => request.fullpath)
  end

  def help(url)
    # link_to 'Help', url
  end

  def delete_icon(path, options = nil)
    if !path.is_a? String
      path = send("#{path.class.to_s.underscore}_path", path, options)
    end
    link_to content_tag(:span, '', :class => 'glyphicon glyphicon-delete'), path, :method => :delete, data: {confirm: I18n.t('general.are_you_sure')}
  end

  def edit_icon(path, options = nil)
    if !path.is_a? String
      path = send("edit_#{path.class.to_s.underscore}_path", path, options)
    end
    link_to content_tag(:span, '', class: 'glyphicon glyphicon-edit'), path
  end

  def explain_op(op)
    case op
    when '>' then 'should be greater than' 
    when '>=' then 'should be greater than or equal to' 
    when '<=' then 'should be less than or equal to'
    when '<' then 'should be less than'
    when '=' then 'should be equal to'
    when '!=' then 'should not be equal to'
    end
  end
end
