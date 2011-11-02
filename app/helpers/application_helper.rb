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
      link_to image_tag(clothing_image(clothing, options)), options[:path] ? options[:path] : clothing_path(clothing), { :title => title }
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
end
