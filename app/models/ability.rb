# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= Employee.new # guest user (not logged in)

    if user.role? :admin
      can :manage, :all
    elsif user.role? :manager
      can :manage, Shift
      can :manage, ShiftJob
      can :index, Store
      can :show, Store do |store|
        store.id == user.current_assignment.store_id
      end
      can :index, Assignment
      can :show, Assignment do |assignment|
        assignment.store_id == user.current_assignment.store_id
      end
      can :index, Employee
      can :show, Employee do |employee|
        employee.current_assignment.store_id == user.current_assignment.store_id
      end
      can :edit, Employee do |employee|
        employee.current_assignment.store_id == user.current_assignment.store_id
      end
      can :update, Employee do |employee|
        employee.current_assignment.store_id == user.current_assignment.store_id
      end
    elsif user.role? :employee
      can :index, Assignment
      can :show, Assignment do |assignment|
        assignment.employee_id == user.id
      end
      can :show, Employee do |employee|
        employee.id == user.id
      end
      can :edit, Employee do |employee|
        employee.id == user.id
      end
      can :update, Employee do |employee|
        employee.id == user.id
      end
    else
      can :read, :all
    end

  end
end
