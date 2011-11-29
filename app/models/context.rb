class Context < ActiveRecord::Base
  belongs_to :user
  def rules_array
    self.rules.split /[\r\n]+/
  end

  def stuff_rules
    rules = self.rules_array
    stuff = Hash.new { |h,k| h[k] = Hash.new }
    rules.each do |r|
      matches = r.match(/^stuff:[ \t]*([^,]+),[ \t]*(.*)/)
      if matches
        stuff[matches[1]][:destination] = matches[2]
      end
    end
    stuff_hash = self.user.stuff.includes(:location).where('name in (?)', stuff.keys)
    stuff_hash.each do |s|
      stuff[s.name][:stuff] = s
      stuff[s.name][:in_place] = (s.location and s.location.name == stuff[s.name][:destination])
    end
    stuff
  end

end
