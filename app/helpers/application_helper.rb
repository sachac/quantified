module ApplicationHelper
  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end
  def google_analytics_js
  end	
  def clothing_image(clothing, options = {})
    if clothing then
      case options[:size]  
        when :large then
          base = "#{clothing.id}.jpg"
        else	
	  base = "small-#{clothing.id}.jpg"
      end
      if File.exist?("#{Rails.root}/public/images/clothing/#{base}") then
        image = "/images/clothing/#{base}"
      else
        image = "/images/clothing/clothing_unknown.jpg"
      end
    end
    image || nil
  end
  def clothing_thumbnail(clothing, options = {})
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
    else
      "Unknown"
    end
  end
  def date_ago_future(d)
    if d then
      if d >= Date.tomorrow then
        d
      elsif d >= Date.today then
        'today'
      else
        pluralize((Date.today - d.to_date).to_i, "day") + " ago"
      end
    end
  end

  def return_stuff(stuff)
    link_to stuff.home_location.name, log_stuff_path(:stuff_name => stuff.name, :destination => request.url, :location_name => stuff.home_location.name), :method => :post
  end

  def set_stuff_home(stuff, loc)
    loc = Stuff.get_location(loc)
    link_to 'Set home', stuff_path(stuff.id, :destination => request.url, :stuff => {:home_location => loc}), :method => :put
  end

  def return_stuff_info(stuff)
    if stuff.location 
      if stuff.home_location
        "<strong>#{link_to stuff.name, stuff}</strong> #{stuff.location.name} #{h '=>'} #{return_stuff(stuff)}".html_safe
      else
        "<strong>#{link_to stuff.name, stuff}</strong> #{stuff.location.name} #{h '=>'} #{set_stuff_home(stuff, stuff.location)}".html_safe
      end
    end
  end

  def recent_locations(stuff)
    loc = stuff.distinct_locations
    stuff.recent_locations = loc.map { |l|
      url_helpers.link_to(l.location.name, url_helpers.log_stuff_path(:stuff_name => stuff.name, :location_name => l.location.name), :method => :post) if l and l.location
    }.join(' ').html_safe
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

  def move_stuff_link(stuff, location, destination = nil)
    location_name = location.is_a?(String) ? location : location.name
    link_to location_name, log_stuff_path(:stuff_name => stuff.name, :location_name => location_name, :destination => destination), :method => :post
  end

  def conditional_html( lang = "en", &block )
    haml_concat Haml::Util::html_safe <<-"HTML".gsub( /^\s+/, '' )
    <!--[if lt IE 7 ]>              <html lang="#{lang}" class="no-js ie6"> <![endif]-->
    <!--[if IE 7 ]>                 <html lang="#{lang}" class="no-js ie7"> <![endif]-->
    <!--[if IE 8 ]>                 <html lang="#{lang}" class="no-js ie8"> <![endif]-->
    <!--[if IE 9 ]>                 <html lang="#{lang}" class="no-js ie9"> <![endif]-->
    <!--[if (gte IE 9)|!(IE)]><!--> <html lang="#{lang}" class="no-js"> <!--<![endif]-->      
  HTML
    haml_concat capture( &block ) << Haml::Util::html_safe( "\n</html>" ) if block_given?
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
    actions = Array.new
    if o.is_a? Memory
      if can? :update, o
        actions << link_to(I18n.t('app.general.edit'), edit_memory_path(o))
        actions << link_to(I18n.t('app.general.delete'), o, :confirm => I18n.t('app.general.are_you_sure'), :method => :delete)
      else
        actions << link_to(I18n.t('app.general.view'), memory_path(o))
      end
    elsif o.is_a? RecordCategory
      if can? :manage_account, current_account
        case o.category_type
        when 'activity'
          actions << link_to(t('record_categories.show.start_activity'), track_time_path(:category_id => o.id), :method => :post)
        when 'record'
          actions << link_to(t('record_categories.show.record'), track_time_path(:category_id => o.id), :method => :post)
        end
        actions << link_to(t('app.general.edit'), edit_record_category_path(o))
      end
    elsif o.is_a? Record
      if can? :manage_account, current_account
        actions << link_to('Edit', edit_record_path(o))
        actions << link_to('Clone', clone_record_path(o), :method => :post)
        actions << link_to('Delete', o, :confirm => 'Are you sure?', :method => :delete)
      end
    elsif o.is_a? Context
      if managing?
        actions << link_to('Edit', edit_context_path(o))
        actions << link_to('Start', start_context_path(o))
      end
    end
    actions
  end

  def tags(o)
    o.tag_list.join(', ')
  end

  def action_list(o)
    actions(o).join(' | ').html_safe
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
    content_for(:nav) { render nav_file, :active => active }
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
    elsif request.fullpath.start_with? crumb
      active = true
    end
    active ? 'active' : 'inactive'
  end

  def duration(seconds)
    "%d" % (seconds / 1.hour) + (":%02d" % ((seconds % 1.hour) / 1.minute)) if seconds and seconds > 0
  end

  def record_category_breadcrumbs(category)
    ([link_to t('app.general.home'), record_categories_path] + category.ancestors.reverse.map{ |c| link_to c.name, c }).join(' &raquo; ').html_safe
  end

  def record_category_full(category)
    category.self_and_ancestors.reverse.map{ |c| link_to c.name, c }.join(' &raquo; ').html_safe
  end

  def record_data(data)
    return '' unless data
    if data.length == 1
      content_tag(:strong, data.keys.first.to_s.humanize) + ": " + data.values.first
    elsif data.length > 0
      content_tag(:ul, data.map { |k, v| content_tag(:li, (content_tag(:strong, k.to_s.humanize).html_safe + ": " + v.html_safe).html_safe) }.join.html_safe).html_safe
    else
      ''
    end
  end

  def graph_time_entry(day_offset, row)
    # Turn this into the Javascript call
    # Javascript needs start time, end time, title, color, and duration
    logger.info(row.inspect)
    start_offset = row[0] - row[0].midnight.in_time_zone
    end_offset = row[1] - row[0].midnight.in_time_zone
    "graphTimeEntry(#{day_offset}, #{start_offset}, #{end_offset}, " +
      "'#{escape_javascript row[0].strftime('%Y-%m-%d %-H:%M')} - #{escape_javascript row[1].strftime('%-H:%M')}: " +
      "#{escape_javascript row[2].full_name} (#{escape_javascript(duration(row[1] - row[0]))})', " +
      "'#{escape_javascript row[2].color}', '#{row[2].record_category.full_name.parameterize.underscore}');"
  end

  def record_data_input(record, info, index = nil)
    content_tag(:div, :class => 'clearfix optional stringish') do
      key = info[:key] || info["key"]
      label = info[:label] || info["label"] || key
      if key
        s = label_tag("data[#{key}]", label)
        s += content_tag(:div, :class => 'input') do
          case info[:type]
          when 'text'
            text_area_tag("record[data][#{key}]", record.data ? record.data[key] : nil, :autofocus => (index == 0))
          else
            text_field_tag("record[data][#{key}]", record.data ? record.data[key] : nil, :autofocus => (index == 0))
          end
        end
        s
      end
    end
  end

  def download_as_spreadsheet
    content_tag(:div, link_to(t('general.download_as_spreadsheet'), params.merge(:format => :xls)), :class => 'spreadsheet')
  end

  def feedback_link(text = 'send feedback')
    link_to text, feedback_path(:old_params => params.inspect, :destination => request.fullpath)
  end

  def help(url)
    # link_to 'Help', url
  end
end
