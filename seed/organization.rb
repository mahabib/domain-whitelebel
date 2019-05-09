require_relative '../app'

recs = [
  {:name=>'Demo', :description=>'Lorem ipsum dollar sit amet'},
  {:name=>'Test', :description=>'Lorem ipsum dollar sit amet'},
  {:name=>'Abc', :description=>'Lorem ipsum dollar sit amet'}]

recs.each do |rec|
  Organization.create_organization(rec)
end