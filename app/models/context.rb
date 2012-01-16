class Context < ActiveRecord::Base
  belongs_to :user
  has_many :context_rules
  accepts_nested_attributes_for :context_rules, :allow_destroy => true
  validates_presence_of :name
  before_save :update_rules

  def update_rules
    self.rules = self.context_rules.includes(:stuff).order('LOWER(stuff.name)').map { |x| x.stuff.name }.join(', ')
  end
end
