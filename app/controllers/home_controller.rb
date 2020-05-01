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

  def search
    redirect_back(fallback_location: employees_path) if params[:query].blank?
    @query = params[:query]
    @employees = Employee.search(@query)
    @total_hits = @employees.size
    @employees = @employees.paginate(page: params[:page]).per_page(10)
    if current_user.role? :manager
      current_store = current_user.current_assignment.store
      arr = current_store.assignments.current.map{|a| a.employee}.sort_by{|e| e.name}
      @employees = @employees.where(id: arr.map(&:id))
      @total_hits = @employees.size
    end
    if @total_hits == 1
      redirect_to @employees.first, notice: "Search for '#{@query}' resulted in #{@employees.first.proper_name}."
    end
  end
  
end