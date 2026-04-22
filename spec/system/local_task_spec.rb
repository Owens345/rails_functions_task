require 'rails_helper'

RSpec.describe do
  before(:each) do
    driven_by(:rack_test)
  end

  describe do
    it '1. profile_image form field exists' do
      visit new_user_path
      expect(page).to have_selector('input[name="user[profile_image]"]')
    end
  end

  describe do
    before do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/test.png"
      find('input[type="submit"]').click
    end

    it '2. can register with profile image' do
      expect(page).to have_content 'アカウントを登録しました。'
    end

    it '3. Active Storage is used' do
      expect(User.last.profile_image.class).to eq ActiveStorage::Attached::One
    end

    it '4. redirected to details page with image displayed' do
      expect(current_path).to eq user_path(User.last.id)
      expect(page).to have_selector('img')
    end
  end

  describe do
    it '5. can register without profile image' do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      find('input[type="submit"]').click
      expect(current_path).to eq user_path(User.last.id)
    end
  end

  describe do
    it '6. sends email on registration' do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/test.png"
      perform_enqueued_jobs do
        find('input[type="submit"]').click
      end
      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq ['user@gmail.com']
    end
  end

  describe do
    it '7. email has correct subject and sender' do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/test.png"
      perform_enqueued_jobs do
        find('input[type="submit"]').click
      end
      email = ActionMailer::Base.deliveries.last
      expect(email.from).to eq ['admin@example.com']
      expect(email.subject).to eq '登録完了'
    end
  end

  describe do
    it '8. email is sent asynchronously via ActiveJob' do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/test.png"
      expect { find('input[type="submit"]').click }.to change { enqueued_jobs.size }.by(2)
    end
  end
end
