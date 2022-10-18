class UserPolicy
  attr_reader :current_user

  def initialize(current_user, record)
    @current_user = current_user
    @record = record
  end

  def scope
    Pundit.policy_scope!(current_user, @record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
