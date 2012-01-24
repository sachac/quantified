class ChangeContextToSerialize < ActiveRecord::Migration
  def up
    # Convert string-based context rule definitions to model-based rule definitions
    Context.all.each do |c|
      rules = c.rules.split(/[\r\n]+/)
      rules.each do |r|
        matches = r.match(/^stuff:[ \t]*([^,]+),[ \t]*(.*)/)
        if matches
          stuff = c.user.stuff.find_by_name matches[1]
          location = c.user.stuff.find_by_name matches[2]
          c.context_rules << ContextRule.new(:stuff => stuff, :location => location)
        end
      end
      c.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
