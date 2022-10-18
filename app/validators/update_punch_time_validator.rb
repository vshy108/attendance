require 'dry-validation'

class UpdatePunchTimeValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      option :record

      # class is reversed keyword
      def record?(klass, value)
        klass.where(id: value).lazy.any?
      end

      def convert_datetime_and_lteq?(target_time, value)
        value.in_time_zone.change(sec: 0) <= target_time
      rescue ArgumentError
        false
      end

      def current_datetime
        Time.zone.now
      end
    end

    # from form input, all input is string
    required(:punched_datetime).filled(:str?, convert_datetime_and_lteq?: current_datetime)
    required(:worker_id).filled(:int?, record?: Worker)

    validate(repeated_punched_datetime: %i[worker_id punched_datetime]) do |worker_id, punched_datetime|
      worker = Worker.find_by(id: worker_id).presence
      if worker.present?
        worker.punch_times.where.not(
          id: record.id
        ).where(
          punched_datetime: punched_datetime.in_time_zone.change(sec: 0)
        ).lazy.none?
      else
        true
      end
    end
  end
end
