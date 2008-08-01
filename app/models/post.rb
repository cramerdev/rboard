class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  belongs_to :editor, :class_name => "User", :foreign_key => "edited_by_id"
  validates_length_of :text, :minimum => 4
  validates_presence_of :text
  
  after_create :update_forum
  after_destroy :find_latest_post
  
  def update_forum
    forum.last_post = self
    Post.update_latest_post(self)
  end
  
  def self.update_latest_post(post)
    post.forum.last_post = post
    if post.forum.sub? 
      for ancestor in post.forum.ancestors
        ancestor.last_post = post
        ancestor.last_post_forum = post.forum
        ancestor.save
      end
    end
    post.forum.last_post = post
    post.forum.last_post_forum = nil
    post.forum.save
  end
  
  def find_latest_post
    last = forum.posts.last
    if !last.nil?
      Post.update_latest_post(last)
    else
      #probably does not set the ancestors last_posts correctly
      forum.last_post = nil
      forum.last_post_forum = nil
      forum.save
    end

  end
  
  def forum
    topic.forum
  end
end
