class OverlapTimeValidator < ActiveModel::Validator
  def validate record
    overlap_time_handler = OverlapTimeHandler.new(record)

    return unless overlap_time_handler.valid?

    record.errors[:time] << I18n.t("validator.time.overlap")
  end
end
