module StuffHelper
  def name_and_location(stuff)
    s = stuff.name
    if stuff.location
      s += ' < ' + stuff.hierarchy.map {|l| link_to h(l.name), l}.join(h(' < ')).html_safe
    end
    if managing?
       if stuff.stuff_type == 'stuff' and stuff.home_location and stuff.location != stuff.home_location
         s += ' ' + link_to("(return to #{stuff.home_location.name})", log_stuff_path(:stuff_name => stuff.name, :location_name => stuff.home_location.name), :method => :post)
       end
    end
    s
  end

  def move_link_to(stuff, location)
    if managing?
      s = link_to location.name, log_stuff_path(:stuff_name => stuff.name, :location_name => location.name), :method => :post
      s += ' ('
      s += link_to 'view', location
      s += ')'
      s
    else
      link_to location.name, location
    end
  end

  def location_list(stuff, list) 
    list.map { |location| move_link_to(stuff, location) }.join(', ').html_safe
  end
end
