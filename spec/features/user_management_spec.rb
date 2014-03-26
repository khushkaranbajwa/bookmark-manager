require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "User signs up" do
  scenario "when signing up and logging in" do
    lambda {sign_up}.should change(User, :count).by(1)
    expect(page).to have_content("Welcome, alice@example.com")
    expect(User.first.email).to eq("alice@example.com")
  end

  scenario "with a password that doesn't match" do
    lambda {sign_up('a@a.com','pass','wrong')}.should change(User, :count).by(0)
    expect(current_path).to eq('/users')
    expect(page).to have_content("Sorry, your passwords don't match")
  end

  scenario "with an email that is already registered" do
    lambda { sign_up }.should change(User, :count).by(1)
    lambda { sign_up }.should change(User, :count).by(0)
    expect(page).to have_content("This email has already been taken")
  end

end

feature "User signs in" do
  before(:each) do
    User.create(:email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
  end

  scenario "with correct credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    expect(page).to have_content("Welcome, test@test.com")
  end

  scenario "with incorrect credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'wrong')
    expect(page).not_to have_content("Welcome, test@test.com")
  end
end

feature "User signs out" do
  before(:each) do
    User.create(:email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
  end
  scenario "while being signed in" do
    sign_in('test@test.com', 'test')
    click_button "Sign out"
    expect(page).to have_content("Good bye!")
    expect(page).not_to have_content("Welcome, test@test.com")
  end
end

feature "Favourites" do
  scenario "User favourites a link" do
    User.create(:email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
    Link.create(:url => "http://www.google.com", :title => "Google", :tags => [Tag.first_or_create(:text => 'search')], :user_id => 1)
    sign_in('test@test.com', 'test')
    user = User.first
    visit '/'
    click_button 'Favourite Google'
    expect(user.links.map(&:title)).to include("Google")
    expect(page).to have_content("1 added yesterday by ")
  end
end
