module ApplicationHelper
  def bootstrap_flash_class(flash_type)
    {success: 'alert-success',
     error: 'alert-danger',
     alert: 'alert-warning',
     notice: 'alert-info'
    }[flash_type.to_sym] || flash_type.to_s
  end

  def page_title
    @title || controller_name.gsub(/Controller/, "").humanize
  end

  def has_policy(record, actions, devise_controller = nil)
    return true if current_user.god?
    record = record.classify.constantize if record.is_a? String
    actions.each { |query| return true if policy(record).send('general_policy', record, query, devise_controller) }
    false
  end

  def collection_scope(user, scope)
    policy_name = (scope.to_s + 'Policy').classify.constantize
    policy_name::ScopeActions.new(user, scope).collection_scope
  end

  def current_translations
    @translator = I18n.backend
    @translator.load_translations
    @translations = @translator.send(:translations)[I18n.locale][:messages]
  end

  def custom_paginator(resource)
    will_paginate resource, renderer: BootstrapPagination::Rails,
                  next_label: '<i class="fa fa-chevron-right"></i>'.html_safe,
                  previous_label: '<i class="fa fa-chevron-left"></i>'.html_safe
  end
end
