class HolidaysController < ApplicationController
  before_action :set_holiday, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /holidays
  def index
    @search = Holiday.ransack(params[:q])
    ransack_holidays = @search.result(distinct: true)
    @pagy, @holidays = pagy(ransack_holidays.order(valid_date: :desc))
  end

  # GET /holidays/1
  def show
  end

  # GET /holidays/new
  def new
    @holiday = Holiday.new
  end

  # GET /holidays/1/edit
  def edit
  end

  # POST /holidays
  def create
    @holiday = Holiday.new
    validation_result = CreateHolidayValidator::Schema.call(holiday_params.to_h)
    if validation_result.success?
      @holiday.attributes = validation_result.output
      @holiday.save
      redirect_to @holiday, notice: 'Holiday was successfully created.'
    else
      @errors = validation_result.messages(full: true)
      @holiday = Holiday.new(holiday_params)
      render :new
    end
  end

  # PATCH/PUT /holidays/1
  def update
    validation_result = UpdateHolidayValidator::Schema.with(
      record: @holiday
    ).call(holiday_params.to_h)
    if validation_result.success?
      @holiday.update(validation_result.output)
      redirect_to @holiday, notice: 'Holiday was successfully updated.'
    else
      @errors = validation_result.messages(full: true)
      render :edit
    end
  end

  # DELETE /holidays/1
  def destroy
    @holiday.destroy
    redirect_to holidays_url, notice: 'Holiday was successfully destroyed.'
  end

  private

  def set_holiday
    @holiday = Holiday.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def holiday_params
    params.require(:holiday).permit(:valid_date, :name, :description)
  end
end
