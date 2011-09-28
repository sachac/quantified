class Color::HSL
  def self.from_html(string) 
    rgb = Color::RGB.from_html(string)
    rgb.to_hsl
  end
  def complementary
    c = self.clone
    c.hue = c.hue + 180
    c
  end
end
