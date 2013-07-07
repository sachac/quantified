class User < ActiveRecord::Base
  has_many :clothing_logs
  has_many :receipt_items
  has_many :clothing_matches
  has_many :goals
  has_many :clothing
  has_many :csa_foods
  has_many :days
  has_many :decision_logs
  has_many :decisions
  has_many :foods
  has_many :library_items
  has_many :location_histories
  has_many :locations
  has_many :measurement_logs
  has_many :measurements
  has_many :stuff
  has_many :time_records
  has_many :toronto_libraries
  has_many :contexts
  has_many :memories
  has_many :tap_log_records
  has_many :record_categories
  has_many :records
  has_many :services, :dependent => :destroy
  has_one :time_tracker_log

  validates :username, :exclusion => { :in => %w(admin superuser root www) }
  # validates :username, :presence => true
  validates_length_of :username, :maximum => 20, :allow_blank => true
  validates :username, :uniqueness => { :case_sensitive => false }, :allow_blank => true
  validates :email, :presence => true, :email => true
  validates :email, :uniqueness => { :case_sensitive => false }
  validates_format_of :username, :with => /^[A-Za-z\d]*$/
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :confirmable
  attr_accessor :login

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :login
  before_save :update_memento_mori 

  acts_as_tagger
  
  include RailsSettings::Extend 

  def adjust_beginning_of_week(date)
    if date.wday == 6
      date
    else
      date - date.wday.days - 1.day
    end
  end

  def beginning_of_week
    self.adjust_beginning_of_week(Time.zone.today.midnight)
  end

  def this_week
    beginning = self.beginning_of_week
    beginning..(beginning + 1.week)
  end

  def update_memento_mori
    if birthdate_changed? or life_expectancy_in_years_changed? then
      self.projected_end = birthdate + life_expectancy_in_years.to_i.years
    end
  end

  def memento_mori
    if self.projected_end then
      days = (self.projected_end - Time.zone.today)
      { :days => days.to_i, :months => (days * 1.day / 1.month).to_i, :years => (days * 1.day / 1.year).to_i, :weeks => (days * 1.day / 1.week).to_i }
    end
  end

  def get_location(val)
    if val.is_a? String
      if match = val.match(/^([0-9]+)/)
        self.stuff.find_by_id(val)
      else  
        loc = self.stuff.find(:first, :conditions => ['lower(name)=?', val.downcase.strip])
        loc ||= self.stuff.create(:name => val.strip, :stuff_type => 'location')
      end
    else
      val
    end
  end

  def admin?
    self.role == 'admin'
  end
#  def active_for_authentication? 
#    super && (approved? || self.admin?)
#  end 

  # def inactive_message 
  #   if !approved? 
  #     :not_approved 
  #   else 
  #     super # Use whatever other message 
  #   end 
  # end

  def demo?
    (self.email == 'sacha@sachachua.com') || (self.role == 'demo')
  end

  protected

  # Attempt to find a user by email. If a record is found, send new
  # password instructions to it. If not user is found, returns a new user
  # with an email not found error.
  def self.send_reset_password_instructions(attributes={})
    recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end 

  def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
    (case_insensitive_keys || []).each { |k| attributes[k].try(:downcase!) }

    attributes = attributes.slice(*required_attributes)
    attributes.delete_if { |key, value| value.blank? }

    if attributes.size == required_attributes.size
      conditions = attributes.dup
      login = conditions.delete(:login)
      record = where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    end  

    unless record
      record = new
      required_attributes.each do |key|
        value = attributes[key]
        record.send("#{key}=", value)
        record.errors.add(key, value.present? ? error : :blank)
      end  
    end  
    record
  end

  def self.find_record(username)
    where(["username = :value OR email = :value", { :value => username }]).first
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  end
 
  fires :new, :on => :create, :actor => :self
  fires :update, :on => :update, :actor => :self
end
