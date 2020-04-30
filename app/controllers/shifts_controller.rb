class ShiftsController < ApplicationController
    before_action :set_shift, only: [:show, :edit, :update, :destroy]
    before_action :check_login
    authorize_resource

    def index
        @upcoming_shifts = Shift.upcoming.chronological.paginate(page: params[:page]).per_page(10)
        @past_shifts = Shift.past.chronological.paginate(page: params[:page]).per_page(10)
        if current_user.role? :manager
            curr_store = current_user.current_assignment.store
            @upcoming_shifts = @upcoming_shifts.for_store(curr_store)
            @past_shifts = @past_shifts.for_store(curr_store)
        elsif current_user.role? :employee
            @upcoming_shifts = @upcoming_shifts.for_employee(current_user)
            @past_shifts = @past_shifts.for_employee(current_user)
        end
    end

    def show
        @shiftjobs = @shift.jobs.alphabetical.paginate(page: params[:page]).per_page(10)
    end

    def new
        @shift = Shift.new
    end
    
    def edit
        
    end
    
    def create
        sp = shift_params
        sp[:assignment_id] = Employee.find(sp[:employee_id]).current_assignment.id
        @shift = Shift.new(sp)
        if @shift.save
            redirect_to @shift, notice: "Successfully added shift."
        else
            render action: 'new'
        end
    end
    
    def update
        sp = shift_params
        sp[:assignment_id] = Employee.find(sp[:employee_id]).current_assignment.id
        if @shift.update_attributes(sp)
          redirect_to @shift, notice: "Updated shift's information."
        else
          render action: 'edit'
        end
    end

    def destroy
        @shift.destroy
        redirect_to shifts_path, notice: "Removed job from the system."
      end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
        @shift = Shift.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
        params.require(:shift).permit(:assignment_id, :employee_id, :date, :status, :start_time, :end_time, :notes, job_ids: [])
    end

end