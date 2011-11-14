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
      if File.exist?("#{RAILS_ROOT}/public/images/clothing/#{base}") then
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
        link_to image_tag(clothing_image(clothing, options), :width => 27), options[:path] ? options[:path] : clothing_path(clothing), { :title => title }
      else
        link_to image_tag(clothing_image(clothing, options)), options[:path] ? options[:path] : clothing_path(clothing), { :title => title }
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

  def title(title)
    "<h2>" + title + "</h2>"
  end

  def move_stuff_link(stuff, location, destination = nil)
    location_name = location.is_a?(String) ? location : location.name
    link_to location_name, log_stuff_path(:stuff_name => stuff.name, :location_name => location_name, :destination => destination), :method => :post
  end
end
