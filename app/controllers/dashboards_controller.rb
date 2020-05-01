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
    end

end