class HomeController < ApplicationController
  def index
    if (!current_user.nil?) && (current_user.role? :admin)
      redirect_to admin_dashboard_path
    end
  end

  def about
  end

  def contact
  end

  def privacy
  end
  
end