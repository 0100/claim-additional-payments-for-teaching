module ApplicationHelper
  def page_title(title, show_error: false)
    content_for :page_title do
      [].tap do |a|
        a << "Error" if show_error
        a << title
        a << t("student_loans.policy_name")
        a << "GOV.UK"
      end.join(" - ")
    end
  end

  def currency_value_for_number_field(value)
    return if value.nil?

    number_to_currency(value, delimiter: "", unit: "")
  end

  def support_email_address(policy = nil)
    translation_key = [policy&.underscore, "support_email_address"].compact.join(".")
    t(translation_key)
  end

  def policy_service_name(policy = nil)
    policy ? t("#{policy.underscore}.policy_name") : t("service_name")
  end

  def feedback_url
    "https://docs.google.com/forms/d/e/1FAIpQLSdAyOxHme39E8lMnD2qY029mmk4Lpn84soYg2vLrT5BV9IUSg/viewform?usp=sf_link"
  end
end
