module ApplicationHelper
  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end
  def google_analytics_js
  end	
  def clothing_thumbnail(clothing, options = {})
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
      link_to image_tag(image), options[:path] ? options[:path] : clothing_path(clothing), { :title => clothing.name }
    else
      "Unknown"
    end
  end
end
