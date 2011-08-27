class Clothing < ActiveRecord::Base
  acts_as_taggable
  has_many :clothing_logs
  def autocomplete_view
    "#{self.number} - #{self.name}"
  end
end
