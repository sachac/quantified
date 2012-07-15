class LibraryItem < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable_on :tags
  def self.current_items(account, public_only = false)
    if account
      query = LibraryItem.where("user_id = ? AND (status = 'due' OR status IS NULL OR status = 'read')", account.id).order(:due, :status)
      if public_only
        query = query.where('public=1')
      end
      query
    end
  end
  
  comma do
    library_id
    title
    author
    status
    checkout_date
    due
    return_date
    read_date
    rating
    price
    public
    notes
    dewey
  end
end
