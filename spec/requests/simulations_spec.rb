require 'rails_helper'

RSpec.describe 'Simulations', type: :request do
  describe 'GET /simulations/new' do
    it 'renders the form' do
      get new_simulation_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Date de début')
    end
  end

  describe 'POST /simulations' do
    context 'with valid params' do
      let(:valid_params) do
        { simulation: { start_date: '2023-09-11', end_date: '2025-07-25', monthly_salary: 500 } }
      end

      it 'creates a simulation and redirects to show' do
        expect {
          post simulations_path, params: valid_params
        }.to change(Simulation, :count).by(1)

        expect(response).to redirect_to(simulation_path(Simulation.last))
      end
    end

    context 'with invalid params' do
      it 'rejects salary out of range' do
        post simulations_path, params: { simulation: { start_date: '2024-01-01', end_date: '2024-12-31', monthly_salary: 50 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'rejects end_date before start_date' do
        post simulations_path, params: { simulation: { start_date: '2025-01-01', end_date: '2024-01-01', monthly_salary: 500 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /simulations/:id' do
    it 'displays results with both tables' do
      sim = Simulation.create!(start_date: Date.new(2023, 9, 11), end_date: Date.new(2025, 7, 25), monthly_salary: 500)
      SimulatorService.call(sim)

      get simulation_path(sim)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Périodes de congés')
      expect(response.body).to include('Rémunération mensuelle')
    end
  end
end
