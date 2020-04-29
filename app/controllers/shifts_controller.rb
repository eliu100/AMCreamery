class ShiftsController < ApplicationController
    before_action :set_shift, only: [:show, :edit, :update, :destroy]
    before_action :check_login
    authorize_resource

    def index
        @upcoming_shifts = Shift.upcoming.chronological.paginate(page: params[:page]).per_page(10)
        @past_shifts = Shift.past.chronological.paginate(page: params[:page]).per_page(10)
        if current_user.role? :manager
            @upcoming_shifts = @upcoming_shifts.for_store(current_user.current_assignment.store)
            @past_shifts = @past_shifts.for_store(current_user.current_assignment.store)
        end
    end

    def show
    end

    def new
        @shift = Shift.new
    end
    
    def edit
    end
    
    def create
        @shift = Shift.new(shift_params)
        if @shift.save
            redirect_to @shift, notice: "Successfully added shift."
        else
            render action: 'new'
        end
    end
    
    def update
        if @shift.update_attributes(shift_params)
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
        params.require(:shift).permit(:assignment_id, :date, :start_time, :end_time, :notes)
    end

end