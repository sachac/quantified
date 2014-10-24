class Context < ActiveRecord::Base
  belongs_to :user
  has_many :context_rules
  accepts_nested_attributes_for :context_rules, :allow_destroy => true
  validates_presence_of :name
  before_save :update_rules

  def update_rules
    self.rules = self.context_rules.includes(:stuff).references(:stuff).order('LOWER(stuff.name)').map { |x| x.stuff.name }.uniq.join(', ')
  end
  
  def to_xml(options = {})
    super(options.update(:methods => :context_rules))
  end
  def to_json(options = {})
    super(options.update(:methods => :context_rules))
  end
  
  comma do
    name
    rules
  end
end
