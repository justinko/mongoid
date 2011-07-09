require "spec_helper"

describe Mongoid::Persistence::Operations::Embedded::Insert do

  before do
    Person.delete_all
  end

  describe "#persist" do

    context "when the insert succeeded" do

      let(:person) do
        Person.create(:ssn => "323-21-1111")
      end

      let(:address) do
        person.addresses.create(:street => "Hobrechtstr")
      end

      let(:in_map) do
        Mongoid::IdentityMap.get(Address.where(:_id => address.id))
      end

      it "puts the document in the identity map" do
        in_map.should eq(address)
      end
    end
  end
end
