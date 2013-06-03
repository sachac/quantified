# http://snippets.dzone.com/posts/show/1314
class WpBlogPost < ActiveRecord::Base
  establish_connection Rails.configuration.database_configuration["wordpress"]

  self.table_name = "wp_posts"
  self.primary_key =   "ID"

  has_many :comments, :class_name => "WpBlogComment", :foreign_key => "comment_post_ID"

  def self.find_by_permalink(year, month, day, title)
    find(:first, 
         :conditions => ["YEAR(post_date) = ? AND MONTH(post_date) = ? AND DAYOFMONTH(post_date) = ? AND post_name = ?", year.to_i, month.to_i, day.to_i, title])
  end

  scope :posts, where("post_type='post'")
  scope :published, where("post_status='publish'")
  scope :year, lambda { |year| where("year(post_date)=?", year) }

end 
