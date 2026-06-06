# app/controllers/simulations_controller.rb
class SimulationsController < ApplicationController
  def new
    @simulation = Simulation.new
  end

  def create
    @simulation = Simulation.new(simulation_params)

    if @simulation.save
      SimulatorService.call(@simulation)
      redirect_to @simulation
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @simulation = Simulation.find(params[:id])
    @periods = @simulation.leave_periods.order(:start_date)
    @months = @simulation.month_entries.order(:year, :month)
  end

  private

  def simulation_params
    params.require(:simulation).permit(:start_date, :end_date, :monthly_salary)
  end
end
