class DashboardsController < ApplicationController

    def admin
        @stores = Store.active.alphabetical
    end

end