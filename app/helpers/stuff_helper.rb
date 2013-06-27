module StuffHelper
  def name_and_location(stuff)
    s = stuff.name
    if stuff.location
      s += ' < ' + stuff.hierarchy.map {|l| link_to h(l.name), l}.join(h(' < ')).html_safe
    end
    if managing?
       if stuff.stuff_type == 'stuff' and stuff.home_location and stuff.location != stuff.home_location
         s += ' ' + link_to("(return to #{stuff.home_location.name})", log_stuff_path(:stuff_name => stuff.name, :location_name => stuff.home_location.name), :method => :post).html_safe
       end
    end
    s
  end

  def move_link_to(stuff, location)
    if managing?
      s = (link_to location.name, log_stuff_path(:stuff_name => stuff.name, :location_name => location.name), :method => :post).html_safe
      s += ' ('
      s += (link_to 'view', location).html_safe
      s += ')'
      s.html_safe
    else
      link_to location.name, location
    end
  end

  def location_list(stuff, list) 
    list.map { |location| move_link_to(stuff, location) }.join(', ').html_safe
  end

  def return_stuff(stuff)
    link_to stuff.home_location.name, log_stuff_path(:stuff_name => stuff.name, :destination => request.url, :location_name => stuff.home_location.name), :method => :post
  end

  def set_stuff_home(stuff, loc)
    loc = current_account.get_location(loc)
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
    loc.map { |l|
      link_to(l.location.name, log_stuff_path(:stuff_name => stuff.name, :location_name => l.location.name), :method => :post) if l and l.location
    }.join(' ').html_safe
  end

  def move_stuff_link(stuff, location, destination = nil)
    location_name = location.is_a?(String) ? location : location.name
    link_to location_name, log_stuff_path(:stuff_name => stuff.name, :location_name => location_name, :destination => destination), :method => :post
  end

  
end
