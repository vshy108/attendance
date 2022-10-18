class HomesController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @date_string, @today_string, @q_worker, @other_workers, @pagy, @workers =
      PresenteeAndAbsenteeGenerator.call(params)
  end

  def edit_minimum_punch_diff
    @min_punch_diff_minutes = Setting.min_punch_diff_minutes
  end

  def update_minimum_punch_diff
    validation_result = MinPunchDiffMinutesValidator::Schema.call(home_params.to_h)
    if validation_result.success?
      Setting.min_punch_diff_minutes = validation_result.output[:min_punch_diff_minutes]
      redirect_to setting_path, notice: 'Minimum Minutes Difference was successfully updated.'
    else
      @errors = validation_result.messages(full: true)
      @min_punch_diff_minutes = home_params[:min_punch_diff_minutes]
      render :edit_minimum_punch_diff
    end
  end

  private

  def home_params
    params.require(:home).permit(:min_punch_diff_minutes)
  end
end
