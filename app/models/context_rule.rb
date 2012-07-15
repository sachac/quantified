class ContextRule < ActiveRecord::Base
  belongs_to :stuff
  belongs_to :location, :class_name => 'Stuff'
  belongs_to :context
  delegate :name, :to => :stuff, :prefix => true
  delegate :name, :to => :location, :prefix => true
  
  def to_xml(options = {})
    super(options.update(:methods => [:stuff_name, :location_name]))
  end
  def to_json(options = {})
    super(options.update(:methods => [:stuff_name, :location_name]))
  end

  scope :out_of_place, includes(:stuff).where('(stuff.location_id IS NULL OR stuff.location_id != context_rules.location_id)')
  scope :in_place, includes(:stuff).where('stuff.location_id = context_rules.location_id')
end
