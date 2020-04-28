class PayGradeRatesController < ApplicationController
    before_action :check_login
    authorize_resource

    def new
        @paygraderate = PayGradeRate.new
        @paygraderate.pay_grade_id = params[:pay_grade_id] unless params[:pay_grade_id].nil?
        @paygraderate.start_date = params[:start_date] unless params[:start_date].nil?
    end
    
    def create
        @paygraderate = PayGradeRate.new(paygraderates_params)
        if @paygraderate.save
            redirect_to pay_grade_path(@paygraderate.pay_grade), notice: "Successfully added #{@paygraderate.rate} as a paygrade rate for #{@paygraderate.pay_grade.level}."
        else
            render action: 'new'
        end
    end

    private
    # Never trust parameters from the scary internet, only allow the white list through.
    def paygraderates_params
        params.require(:pay_grade_rate).permit(:pay_grade_id, :rate, :start_date, :end_date)
    end

end