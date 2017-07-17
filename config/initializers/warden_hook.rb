Warden::Manager.after_set_user do |user, auth, opts|
  scope = opts[:scope]

  if user.is_a?(User)
    auth.cookies.signed["#{scope}.id"] = user.id
    auth.cookies.signed["#{scope}.expires_at"] = 30.minutes.from_now
  end
end

Warden::Manager.after_authentication do |user,auth,opts|
  user.make_cable_token! if user.is_a?(User)
end

Warden::Manager.before_logout do |user, auth, opts|
  scope = opts[:scope]

  if user.is_a?(User)
    user.remove_cable_token!
    auth.cookies.signed["#{scope}.id"] = nil
    auth.cookies.signed["#{scope}.expires_at"] = nil
  end
end
