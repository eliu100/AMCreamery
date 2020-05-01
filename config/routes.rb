Rails.application.routes.draw do

  # Semi-static page routes
  get 'home', to: 'home#index', as: :home
  get 'home/about', to: 'home#about', as: :about
  get 'home/contact', to: 'home#contact', as: :contact
  get 'home/privacy', to: 'home#privacy', as: :privacy
  get 'home/search', to: 'home#search', as: :search

  get 'admin', to: 'dashboards#admin', as: :admin_dashboard
  get 'manager', to: 'dashboards#manager', as: :manager_dashboard
  get 'emp', to: 'dashboards#employee', as: :employee_dashboard

  # Resource routes (maps HTTP verbs to controller actions automatically):
  resources :employees
  patch 'employees/:id/clockin', to: 'employees#clock_in', as: :clock_in
  patch 'employees/:id/clockout', to: 'employees#clock_out', as: :clock_out
  resources :stores
  get 'stores/:id/edit_dates', to: 'stores#edit_dates', as: :edit_store_dates
  get 'stores/:id/payroll', to: 'stores#show_payroll', as: :store_payroll
  resources :assignments
  resources :sessions
  resources :pay_grades
  resources :pay_grade_rates
  resources :jobs
  resources :shifts
  get 'shifts/:id/edit_jobs', to: 'shifts#edit_jobs', as: :edit_shift_jobs
  patch 'shifts/:id/update_jobs', to: 'shifts#update_jobs', as: :update_shift_jobs

  # Custom routes
  patch 'assignments/:id/terminate', to: 'assignments#terminate', as: :terminate_assignment
  get 'login' => 'sessions#new', :as => :login
  get 'logout' => 'sessions#destroy', :as => :logout

  # You can have the root of your site routed with 'root'
  root 'home#index'
end
