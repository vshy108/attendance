require 'dry-validation'

class UpdateYearLeaveLimitValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      option :record

      def record?(klass, value)
        klass.where(id: value).lazy.any?
      end
    end

    required(:year_number).filled(:int?, gt?: 2010)
    required(:worker_id).filled(:int?, record?: Worker)
    required(:allowed_annual_days_total).filled(:int?, gteq?: 0)

    validate(repeated_worker_year: %i[worker_id year_number]) do |worker_id, year_number|
      worker = Worker.find_by(id: worker_id).presence
      if worker.present?
        worker.year_leave_limits.where.not(
          id: record.id
        ).where(year_number: year_number).lazy.none?
      else
        true
      end
    end
  end
end
