class ForumsController < ApplicationController
  before_filter :is_visible?, :only => :show
  before_filter :store_location, :only => :show
  
  def index
    @forums = Forum.find_all_without_parent.select { |forum| forum.viewable?(logged_in?, current_user) }
    @forums = @forums.sort_by { |f| f.position.to_i }
    @lusers = User.all(:conditions => ['login_time > ?', Time.now-15.minutes]).map { |u| u.login }.to_sentence
    @users = User.count
    @posts = Post.count
    @topics = Topic.count
    @ppt = @posts > 0 ? @posts / @topics : 0
  end
  
  def show
    @topics = @forum.sorted_topics.paginate :page => params[:page], :per_page => 30, :order => "sticky DESC, id DESC", :include => [:posts => [:user]]
    @forums = @forum.children.sort_by { |f| f.position }
    @all_forums = Forum.all(:select => "id, title", :order => "title ASC") - [@forum] if is_admin? || is_moderator?
    @moderated_topics_count = @forum.moderations.topics.count
  end
  
  private
  def is_visible?
    @forum = Forum.find(params[:id], :include => [{ :topics => :posts }, :moderations])
    if !@forum.viewable?(logged_in?, current_user)
      flash[:notice] = "You do not have the permissions to access that forum."
      redirect_to forums_path
    end
  end
end
