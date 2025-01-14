require 'rails_helper'

RSpec.describe Citizen, type: :model do
  describe 'validations' do
    let(:citizen) { build(:citizen) }

    it 'is valid with all attributes' do
      expect(citizen).to be_valid
    end

    it 'is invalid without a full_name' do
      citizen.full_name = nil
      expect(citizen).to_not be_valid
      expect(citizen.errors[:full_name]).to include("can't be blank")
    end

    it 'is invalid without a tax_id' do
      citizen.tax_id = nil
      expect(citizen).to_not be_valid
      expect(citizen.errors[:tax_id]).to include("can't be blank")
    end

    it 'is invalid without a national_health_card' do
      citizen.national_health_card = nil
      expect(citizen).to_not be_valid
      expect(citizen.errors[:national_health_card]).to include("can't be blank")
    end

    it 'is invalid without an email' do
      citizen.email = nil
      expect(citizen).to_not be_valid
      expect(citizen.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without a birthdate' do
      citizen.birthdate = nil
      expect(citizen).to_not be_valid
      expect(citizen.errors[:birthdate]).to include("can't be blank")
    end

    it 'is invalid without a phone' do
      citizen.phone = nil
      expect(citizen).to_not be_valid
      expect(citizen.errors[:phone]).to include("can't be blank")
    end

    it 'is valid with a false status' do
      citizen.status = false
      expect(citizen).to be_valid
    end

    it 'is valid with a true status' do
      citizen.status = true
      expect(citizen).to be_valid
    end
  end

  describe 'scopes' do
    let(:citizen1) { create(:citizen, full_name: 'Alice Smith', tax_id: '51017822115', national_health_card: '239233319950009', email: 'alice@example.com', birthdate: Date.new(1990, 1, 1), phone: '1234567890', status: true) }
    let(:citizen2) { create(:citizen, full_name: 'Bob Jones', tax_id: '39655368262', national_health_card: '954440753770000', email: 'bob@example.com', birthdate: Date.new(1995, 1, 1), phone: '0987654321', status: false) }

    it 'filters by full_name' do
      expect(Citizen.filter_by_full_name('Alice')).to include(citizen1)
      expect(Citizen.filter_by_full_name('Alice')).to_not include(citizen2)
    end

    it 'filters by tax_id' do
      expect(Citizen.filter_by_tax_id('51017822115')).to include(citizen1)
      expect(Citizen.filter_by_tax_id('51017822115')).to_not include(citizen2)
    end

    it 'filters by national_health_card' do
      expect(Citizen.filter_by_national_health_card('239233319950009')).to include(citizen1)
      expect(Citizen.filter_by_national_health_card('239233319950009')).to_not include(citizen2)
    end

    it 'filters by email' do
      expect(Citizen.filter_by_email('alice@example.com')).to include(citizen1)
      expect(Citizen.filter_by_email('alice@example.com')).to_not include(citizen2)
    end

    it 'filters by birthdate' do
      expect(Citizen.filter_by_birthdate(Date.new(1990, 1, 1))).to include(citizen1)
      expect(Citizen.filter_by_birthdate(Date.new(1990, 1, 1))).to_not include(citizen2)
    end

    it 'filters by phone' do
      expect(Citizen.filter_by_phone('1234567890')).to include(citizen1)
      expect(Citizen.filter_by_phone('1234567890')).to_not include(citizen2)
    end
  end

  describe 'Birthdate validations' do
    let(:valid_attributes) { attributes_for(:citizen).except(:birthdate) }

    it 'is valid with a recent birthdate' do
      citizen = Citizen.new(valid_attributes.merge(birthdate: Date.today - 30.years))
      expect(citizen).to be_valid
    end

    it 'is invalid with a future birthdate' do
      citizen = Citizen.new(valid_attributes.merge(birthdate: Date.tomorrow))
      citizen.valid?
      expect(citizen.errors[:birthdate]).to include("can't be in the future")
    end

    it 'is invalid with a birthdate more than 150 years ago' do
      citizen = Citizen.new(valid_attributes.merge(birthdate: 151.years.ago))
      citizen.valid?
      expect(citizen.errors[:birthdate]).to include("can't be more than 150 years ago")
    end

    it 'is invalid with a non-date birthdate' do
      citizen = Citizen.new(valid_attributes.merge(birthdate: 'not-a-date'))
      citizen.valid?
      expect(citizen.errors[:birthdate]).to include("can't be blank")
    end
  end

  describe 'CPF validations' do
    it 'is valid with a valid CPF' do
      valid_cpf = CPF.generate(true)
      citizen = Citizen.new(tax_id: valid_cpf)
      citizen.valid?
      expect(citizen.errors[:tax_id]).to be_empty
    end

    it 'is invalid with an invalid CPF' do
      citizen = Citizen.new(tax_id: '12345678901')
      citizen.valid?
      expect(citizen.errors[:tax_id]).to include('is not a valid CPF')
    end

    it 'is invalid with a nil CPF' do
      citizen = Citizen.new(tax_id: nil)
      citizen.valid?
      expect(citizen.errors[:tax_id]).to include("can't be blank")
    end
  end

  describe 'CNS validations' do
    it 'is valid with a valid CNS number' do
      citizen = create(:citizen, national_health_card: '239233319950009')
      expect(citizen).to be_valid
    end

    it 'is invalid with an invalid CNS number' do
      citizen = build(:citizen, national_health_card: '239233310000000')
      citizen.valid?
      expect(citizen.errors[:national_health_card]).to include('is not a valid CNS number')
    end

    it 'is invalid with a CNS number of incorrect length' do
      citizen = build(:citizen, national_health_card: 'short')
      citizen.valid?
      expect(citizen.errors[:national_health_card]).to include('is not a valid CNS number')
    end
  end

  describe 'Email validations' do
    it 'is valid with a valid email' do
      citizen = build(:citizen, email: 'test@example.com')
      expect(citizen).to be_valid
    end

    it 'is invalid with an invalid email' do
      invalid_emails = ['test@example', 'test', 'test@.com', 'test@example..com']
      invalid_emails.each do |invalid_email|
        citizen = build(:citizen, email: invalid_email)
        expect(citizen).not_to be_valid
        expect(citizen.errors[:email]).to include('is invalid')
      end
    end

    it 'is invalid without an email' do
      citizen = build(:citizen, email: nil)
      expect(citizen).not_to be_valid
      expect(citizen.errors[:email]).to include("can't be blank")
    end
  end
end
