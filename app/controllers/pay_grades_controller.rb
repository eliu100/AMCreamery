class PayGradesController < ApplicationController
    before_action :set_paygrade, only: [:show, :edit, :update]
    before_action :check_login
    authorize_resource

    def index
        # get data on all stores and paginate the output to 10 per page
        @paygrades = PayGrade.active.alphabetical.paginate(page: params[:page]).per_page(10)
    end

    def show
        @current_rate = @paygrade.pay_grade_rates.current.first
        @previous_rates = @paygrade.pay_grade_rates.chronological.to_a - [@current_rate]
    end

    def new
        @paygrade = PayGrade.new
    end
    
    def edit
    end
    
    def create
        @paygrade = PayGrade.new(paygrade_params)
        if @paygrade.save
            redirect_to @paygrade, notice: "Successfully added #{@paygrade.level} as a paygrade."
        else
            render action: 'new'
        end
    end
    
    def update
        if @paygrade.update_attributes(paygrade_params)
          redirect_to @paygrade, notice: "Updated #{@paygrade.level}'s information."
        else
          render action: 'edit'
        end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_paygrade
        @paygrade = PayGrade.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paygrade_params
        params.require(:pay_grade).permit(:level, :active)
    end

end