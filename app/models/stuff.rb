class Stuff < ActiveRecord::Base
  belongs_to :user
  delegate :url_helpers, :to => 'Rails.application.routes' 

  has_many :location_histories
  belongs_to :location, :class_name => 'Stuff'
  belongs_to :home_location, :class_name => 'Stuff'
  has_many :context_rules
  has_many :contexts, :through => :context_rules
  has_many :contained_stuff, :class_name => 'Stuff', :foreign_key => :location_id
  before_save :update_in_place

  scope :locations, where(:stuff_type => 'location')
  scope :out_of_place, where('location_id != home_location_id')
  def update_in_place
    self.in_place = (self.location and self.home_location and self.location == self.home_location)
    true
  end

  def distinct_locations
    self.location_histories.group('location_id')
  end

  def hierarchy
    seen = []
    list = []
    loc = self.location
    while loc
      list << loc
      break if seen.include? loc 
      loc = loc.location
      seen << loc
    end
    list
  end

  delegate :name, :to => :home_location, :prefix => true
  delegate :name, :to => :location, :prefix => true
  
  # Returns :success => [list of entries], :failure => [list of strings]
  def self.bulk_update(account, location, input)
    success = Array.new
    failure = Array.new
    location = account.get_location(location)
    entries = input.split /\n/
    entries.each do |e|
      item = Stuff.find_or_create(account, e)
      item.location = location
      if item.save
        success << item
      else
        failure << e.strip
      end
    end
    {:success => success, :failure => failure}
  end

  def self.find_or_create(account, name)
    stuff = account.stuff.find(:first, :conditions => [ 'lower(name) = ?', name.strip.downcase ])
    unless stuff
      stuff = account.stuff.new(:name => name.strip, :status => 'active', :stuff_type => 'stuff', :location => @location)
      stuff.user = account
      stuff.save!
    end
    stuff
  end

  comma do
    id
    name
    long_name
    in_place
    location_id
    location_name
    home_location_id
    home_location_name
    price
    notes
  end
  
  def to_xml(options = {})
    super(options.update(:methods => [:home_location_name, :location_name]))
  end
  def to_json(options = {})
    super(options.update(:methods => [:home_location_name, :location_name]))
  end

  
  fires :new, :on => :create, :actor => :user

end
