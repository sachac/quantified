class LibraryItem < ActiveRecord::Base
  acts_as_taggable_on :tags
  def self.current_items(public_only = false)
    query = LibraryItem.where("status = 'due' OR status IS NULL OR status = 'read'").order(:due, :status)
    if public_only
      query = query.where('public=1')
    end
    query
  end
end
