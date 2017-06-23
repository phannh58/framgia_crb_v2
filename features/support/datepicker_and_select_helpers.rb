def select_desired_month_of_year year, year_span, month, month_span, next_month,
  prev_month
  if year_span.text > year
    differ = (year_span.text.to_i - year.to_i) * 12 +
      (Date::MONTHNAMES.index(month_span.text) - month.to_i)
    click_desired_button differ, prev_month
  elsif year_span.text < year
    differ = (year.to_i - year_span.text.to_i) * 12 +
      (month.to_i - Date::MONTHNAMES.index(month_span.text))
    click_desired_button differ, next_month
  else
    select_month_in_same_year month, month_span, next_month, prev_month
  end
end

def select_month_in_same_year month, month_span, next_month, prev_month
  return if Date::MONTHNAMES.index(month_span.text) == month.to_i
  if Date::MONTHNAMES.index(month_span.text) > month.to_i
    click_desired_button (Date::MONTHNAMES.index(month_span.text) - month.to_i),
      prev_month
  else
    click_desired_button (month.to_i - Date::MONTHNAMES.index(month_span.text)),
      next_month
  end
end

def click_desired_button number, button
  number.times{|i| button.click}
end

def select_from_selectbox selectbox, value
  find(selectbox).click
  within selectbox do
    first("option", text: value).click
  end
end
