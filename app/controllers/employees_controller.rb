class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :clock_in, :clock_out, :destroy]
  before_action :check_login
  authorize_resource

  def index
    # for phase 3 only
    @active_managers = Employee.managers.active.alphabetical.paginate(page: params[:page]).per_page(10)
    @active_employees = Employee.regulars.active.alphabetical.paginate(page: params[:page]).per_page(10)
    @inactive_employees = Employee.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
    if current_user.role? :manager
      @active_managers = @active_managers.where(id: current_user.id)
      current_store = current_user.current_assignment.store
      active_arr = current_store.assignments.current.map{|a| a.employee}.sort_by{|e| e.name}
      @active_employees = @active_employees.where(id: active_arr.map(&:id))
    end
  end

  def show
    retrieve_employee_assignments
    @upcoming_shifts = @employee.shifts.for_next_days(7).chronological.paginate(page: params[:page]).per_page(10)
    @past_shifts = @employee.shifts.for_past_days(7).chronological.paginate(page: params[:page]).per_page(10)
  end

  def new
    @employee = Employee.new
  end

  def edit
  end

  def create
    @employee = Employee.new(employee_params_admin)
    if @employee.save
      redirect_to @employee, notice: "Successfully added #{@employee.proper_name} as an employee."
    else
      render action: 'new'
    end
  end

  def update
    if current_user.role? :admin
      if @employee.update_attributes(employee_params_admin)
        redirect_to @employee, notice: "Updated #{@employee.proper_name}'s information."
      else
        render action: 'edit'
      end
    else
      if @employee.update_attributes(employee_params)
        redirect_to @employee, notice: "Updated #{@employee.proper_name}'s information."
      else
        render action: 'edit'
      end
    end
  end

  def clock_in
    @today_shift = @employee.shifts.for_dates(DateRange.new(Date.today)).pending
    unless @today_shift.empty?
      tc = TimeClock.new(@today_shift.first)
      tc.start_shift_at(Time.now)
      redirect_to employee_dashboard_path
    end
  end

  def clock_out
    @started_shift = @employee.shifts.for_dates(DateRange.new(Date.today)).started
    unless @started_shift.empty?
      tc = TimeClock.new(@started_shift.first)
      tc.end_shift_at(Time.now)
      redirect_to employee_dashboard_path
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path, notice: "Removed employee from the system."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params_admin
    params.require(:employee).permit(:first_name, :last_name, :ssn, :phone, :date_of_birth, :role, :active, :username, :password, :password_confirmation)
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :ssn, :phone, :date_of_birth, :active, :username, :password, :password_confirmation)
  end

  def retrieve_employee_assignments
    @current_assignment = @employee.current_assignment
    @previous_assignments = @employee.assignments.to_a - [@current_assignment]
  end

end
