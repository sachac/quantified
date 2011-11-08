class User < ActiveRecord::Base
  has_many :clothing_logs
  has_many :clothing_matches
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
  has_one :time_tracker_log

  validates :username, :exclusion => { :in => %w(admin superuser root www) }
  validates :username, :presence => true
  validates_length_of :username, :maximum => 20
  validates :username, :uniqueness => { :case_sensitive => false }
  validates :email, :presence => true, :email => true
  validates :email, :uniqueness => { :case_sensitive => false }
  validates_format_of :username, :with => /^[A-Za-z\d]+$/
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  before_save :update_memento_mori 

  acts_as_tagger
  has_settings

  def update_memento_mori
    if birthdate_changed? or life_expectancy_in_years_changed? then
      self.projected_end = birthdate + life_expectancy_in_years.to_i.years
    end
  end

  def memento_mori
    if self.projected_end then
      days = (self.projected_end - Date.today)
      { :days => days.to_i, :months => (days * 1.day / 1.month).to_i, :years => (days * 1.day / 1.year).to_i, :weeks => (days * 1.day / 1.week).to_i }
    end
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
      if attributes.has_key?(:username)
        username = attributes.delete(:username)
        record = find_record(username)
      else  
        record = where(attributes).first
      end  
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
end
