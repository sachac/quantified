module ClothingHelper
  include ActsAsTaggableOn::TagsHelper
  def missing_clothing_info(o)
    out = Array.new
    if !o.image.file?
      out << 'image'
    end

    if out.length > 0
      'Needs ' + out.join(' ')
    end
  end
end
