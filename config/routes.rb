Rails.application.routes.draw do
  resources :holidays
  resources :year_leave_limits
  resources :repeat_templates
  resources :punch_times
  resources :workers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'homes#dashboard'
  get 'homes/dashboard'
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }, skip: %i[registrations passwords]
  get 'qr_code/:id', to: 'workers#qr_code', as: :qr_code
  get 'setting', to: 'homes#setting', as: :setting
  resources :working_templates
  get 'report_dashboard', to: 'reports#dashboard', as: :report_dashboard
  get 'process_punch_times', to: 'reports#process_punch_times', as: :process_punch_times
  resources :working_days, only: [:show]
  get 'abnormal_working_days', to: 'working_days#abnormal_working_days', as: :abnormal_working_days
  get 'edit_uncertain_working_day/:id', to: 'punch_times#edit_uncertain_working_day', as: :edit_uncertain_working_day
  put 'edit_uncertain_working_day/:id', to: 'punch_times#update_uncertain_working_day', as: :update_uncertain_working_day
  get 'new_punch_time_for_working_day', to: 'punch_times#new_punch_time_for_working_day', as: :new_punch_time_for_working_day
  post 'new_punch_time_for_working_day', to: 'punch_times#create_punch_time_for_working_day', as: :create_punch_time_for_working_day
  get 'edit_working_template_overtime/:id', to: 'working_templates#edit_working_template_overtime', as: :edit_working_template_overtime
  put 'edit_working_template_overtime/:id', to: 'working_templates#update_working_template_overtime', as: :update_working_template_overtime
  get 'edit_minimum_punch_diff', to: 'homes#edit_minimum_punch_diff', as: :edit_minimum_punch_diff
  put 'edit_minimum_punch_diff', to: 'homes#update_minimum_punch_diff', as: :update_minimum_punch_diff
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', skip:
        %i[
          registrations confirmations passwords omniauth_callbacks
        ]
      resources :punch_times, only: %i[create]
      get 'punch_time_history', to: 'punch_times#history', as: :punch_time_history
    end
  end
end
