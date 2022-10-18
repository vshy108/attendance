require 'dry-validation'

class UpdateWorkingTemplateOvertimeValidator
  Schema = Dry::Validation.Params(AppSchema) do
    configure do
      config.type_specs = true
      option :total_sections_minutes
      option :overtime_type

      def need_override_working_minutes?(value)
        disabled = OvertimeConfig.overtime_types[:disabled]
        direct_after_off_work = OvertimeConfig.overtime_types[:direct_after_off_work]
        no_need_override = [disabled, direct_after_off_work].include?(overtime_type)
        return false if !no_need_override && value.presence.nil?

        true
      end

      def lteq_total_sections_minutes?(value)
        value <= total_sections_minutes
      end
    end

    required(:override_working_minutes, Dry::Types['optional.coercible.integer']) { need_override_working_minutes? & (empty? | (int? > (lteq_total_sections_minutes? & (lt? 1440) & (gteq? 0)))) }
  end
end
