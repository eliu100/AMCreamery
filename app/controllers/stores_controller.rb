class StoresController < ApplicationController

  before_action :set_store, only: [:show, :show_payroll, :edit, :edit_dates, :update, :destroy]
  before_action :check_login
  authorize_resource

  def index
    # get data on all stores and paginate the output to 10 per page
    @active_stores = Store.active.alphabetical.paginate(page: params[:page]).per_page(10)
    @inactive_stores = Store.inactive.alphabetical.paginate(page: params[:ipage]).per_page(10)
    if current_user.role? :manager
      @active_stores = @active_stores.where(id: current_user.current_assignment.store_id)
    end
  end

  def show
    @current_managers = @store.assignments.current.map{|a| a.employee}.sort_by{|e| e.name}.select{|e| e.role == 'manager'}
    @current_employees = @store.assignments.current.map{|a| a.employee}.sort_by{|e| e.name}
    @upcoming_shifts = @store.shifts.for_next_days(7).chronological.paginate(page: params[:page]).per_page(10)
  end

  def show_payroll
    if params[:commit] == 'Last 2 Weeks'
      @calc = PayrollCalculator.new(DateRange.new(2.weeks.ago.to_date, nil))
    elsif params[:commit] == 'Last Month'
      @calc = PayrollCalculator.new(DateRange.new(1.month.ago.to_date, nil))
    else 
      if store_params[:start_date] == '' && store_params[:end_date] == ''
        redirect_to edit_store_dates_path(@store), alert: "No Dates were provided"
      else
        @calc = PayrollCalculator.new(DateRange.new(store_params[:start_date].to_date, store_params[:end_date].to_date))
      end
    end
    unless @calc.nil?
      @payroll = @calc.create_payrolls_for(@store)
    end
  end

  def new
    @store = Store.new
  end

  def edit
  end

  def edit_dates
  end

  def create
    @store = Store.new(store_params)
    if @store.save
      redirect_to @store, notice: "Successfully added #{@store.name} to the system."
    else
      render action: 'new'
    end
  end

  def update
    if @store.update_attributes(store_params)
      redirect_to @store, notice: "Updated store information for #{@store.name}."
    else
      render action: 'edit'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_store
    @store = Store.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def store_params
    params.require(:store).permit(:name, :street, :city, :phone, :state, :zip, :active, :start_date, :end_date)
  end

end
