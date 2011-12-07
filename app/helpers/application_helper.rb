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
        image = "clothing/#{base}"
      else
        image = "clothing/clothing_unknown.jpg"
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
      if options[:size] == :tiny
        link_to image_tag(clothing_image(clothing, options), :width => 27), options[:path] ? options[:path] : clothing_path(clothing), { :title => title, :class => "clothing_#{clothing.id}"}
      else
        link_to image_tag(clothing_image(clothing, options)), options[:path] ? options[:path] : clothing_path(clothing), { :title => title, :class => "clothing_#{clothing.id}"}
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
    end
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
    "%d" % (seconds / 1.hour) + (":%02d" % ((seconds % 1.hour) / 1.minute))
  end

end
