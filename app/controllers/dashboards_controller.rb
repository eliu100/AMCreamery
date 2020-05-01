class DashboardsController < ApplicationController

    def admin
        @stores = Store.active.alphabetical
        @bad = Array.new
        @stores.to_a.each do |s|
            unless s.assignments.current.to_a.reject{|a| a.shifts.for_past_days(14).pending.empty?}.empty?
                arr = Array.new
                arr << s
                arr << s.assignments.current.to_a.reject{|a| a.shifts.for_past_days(14).pending.empty?}.count
                emp = Hash.new
                s.assignments.current.to_a.map{|a| a.employee}.each do |e|
                    if !e.shifts.for_past_days(14).pending.empty?
                        emp[e] = e.shifts.for_past_days(14).pending.count
                    end
                end
                arr << emp
                @bad << arr
            end
        end
        @unemp = Array.new
        @stores.to_a.each do |s|
            unless s.assignments.current.to_a.select{|a| !a.employee.over_18?}.empty?
                arr = Array.new
                arr << s
                arr << s.assignments.current.to_a.select{|a| !a.employee.over_18?}.map{|a| a.employee}
                @unemp << arr
            end
        end
        @stores = @stores.paginate(page: params[:page]).per_page(5)
    end

    def manager
        curr_store = current_user.current_assignment.store
        @today_shifts = Shift.for_store(curr_store).for_next_days(7).chronological.paginate(page: params[:page]).per_page(5)
        @no_jobs_shifts = Shift.for_store(curr_store).finished.incomplete.chronological.paginate(page: params[:page]).per_page(5)
        active_employees = Employee.regulars.active.alphabetical.paginate(page: params[:page]).per_page(10)
        arr = curr_store.assignments.current.map{|a| a.employee}.sort_by{|e| e.name}
        @emps = active_employees.where(id: arr.map(&:id))
    end

    def employee
        emp = current_user
        @upcoming_shifts = emp.shifts.for_next_days(7).chronological.paginate(page: params[:page]).per_page(10)
        @payreport = PayrollCalculator.new(DateRange.new(7.days.ago.to_date)).create_payroll_record_for(emp)
        @today_shift = emp.shifts.for_dates(DateRange.new(Date.today)).pending
        @started_shift = emp.shifts.for_dates(DateRange.new(Date.today)).started
    end 

end