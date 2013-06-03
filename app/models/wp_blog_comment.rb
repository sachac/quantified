# http://snippets.dzone.com/posts/show/1314
class WpBlogComment < ActiveRecord::Base
  establish_connection Rails.configuration.database_configuration["wordpress"]

  # if wordpress tables live in a different database (i.e. 'wordpress') change the following
  # line to set_table_name "wordpress.wp_comments"
  # don't forget to give the db user permissions to access the wordpress db
  self.table_name = "wp_comments"
  self.primary_key = "comment_ID"

  belongs_to :post , :class_name => "WpBlogPost", :foreign_key => "comment_post_ID"

  validates_presence_of :comment_post_ID, :comment_author, :comment_content, :comment_author_email
  
  def validate_on_create
    if WpBlogPost.find(comment_post_ID).comment_status != 'open'
      errors.add_to_base('Sorry, comments are closed for this post')
    end
  end

end 
