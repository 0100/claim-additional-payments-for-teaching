module MathsAndPhysics
  # Used to display the information a claim checker needs to check to either
  # approve or reject a claim.
  class AdminTasksPresenter
    include Admin::PresenterMethods

    attr_reader :claim

    def initialize(claim)
      @claim = claim
    end

    def qualifications
      [].tap do |a|
        a << ["Award year", eligibility.qts_award_year_answer]
        a << ["ITT subject", itt_subject]
        a << ["Maths or Physics degree", maths_or_physics_degree] if eligibility.has_uk_maths_or_physics_degree.present?
      end
    end

    def employment
      [
        [translate("admin.current_school"), display_school(eligibility.current_school)]
      ]
    end

    def identity_confirmation
      [
        ["Current school", eligibility.current_school.name],
        ["Contact number", eligibility.current_school.phone_number]
      ]
    end

    private

    def eligibility
      claim.eligibility
    end

    def itt_subject
      (eligibility.initial_teacher_training_subject_specialism || eligibility.initial_teacher_training_subject).humanize
    end

    def maths_or_physics_degree
      if eligibility.has_uk_maths_or_physics_degree == "yes"
        "UK Maths or Physics degree"
      elsif eligibility.has_uk_maths_or_physics_degree == "has_non_uk"
        "Non-UK Maths or Physics degree"
      end
    end
  end
end
