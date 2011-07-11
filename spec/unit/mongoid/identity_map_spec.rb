require "spec_helper"

describe Mongoid::IdentityMap do

  let(:identity_map) do
    described_class.new
  end

  context "when executing on the current thread" do

    describe "#clear" do

      before do
        identity_map.set(Person.new)
      end

      let!(:clear) do
        identity_map.clear
      end

      it "empties the identity map" do
        identity_map.should be_empty
      end

      it "returns an empty hash" do
        clear.should eq({})
      end
    end

    describe ".clear" do

      before do
        described_class.set(Person.new)
      end

      let!(:clear) do
        described_class.clear
      end

      it "returns an empty hash" do
        clear.should eq({})
      end
    end

    describe "#executed!" do

      before do
        identity_map.executed!(Person.all)
      end

      it "marks the criteria as executed" do
        identity_map.should be_executed(Person.all)
      end
    end

    describe ".executed!" do

      before do
        described_class.executed!(Person.all)
      end

      it "marks the criteria as executed" do
        described_class.should be_executed(Person.all)
      end
    end

    describe "#executed?" do

      context "when the criteria has been executed" do

        before do
          identity_map.executed!(Person.all)
        end

        it "returns true" do
          identity_map.should be_executed(Person.all)
        end
      end

      context "when the criteria has not been executed" do

        it "returns false" do
          identity_map.should_not be_executed(Person.all)
        end
      end
    end

    describe "#executed?" do

      context "when the criteria has been executed" do

        before do
          described_class.executed!(Person.all)
        end

        it "returns true" do
          described_class.should be_executed(Person.all)
        end
      end

      context "when the criteria has not been executed" do

        it "returns false" do
          described_class.should_not be_executed(Person.all)
        end
      end
    end

    describe "#get" do

      let(:document) do
        Person.new
      end

      context "when the document exists in the identity map" do

        before do
          identity_map.set(document)
        end

        let(:get) do
          identity_map.get(Person.where(:_id => document.id))
        end

        it "returns the matching document" do
          get.should eq(document)
        end
      end

      context "when the document does not exist in the map" do

        let(:get) do
          identity_map.get(Person.where(:_id => document.id))
        end

        it "returns nil" do
          get.should be_nil
        end
      end
    end

    describe ".get" do

      let(:document) do
        Person.new
      end

      context "when the document exists in the identity map" do

        before do
          described_class.set(document)
        end

        let(:get) do
          described_class.get(Person.where(:_id => document.id))
        end

        it "returns the matching document" do
          get.should eq(document)
        end
      end

      context "when the document does not exist in the map" do

        let(:get) do
          described_class.get(Person.where(:_id => document.id))
        end

        it "returns nil" do
          get.should be_nil
        end
      end
    end

    describe "#get_multi" do

      let(:document_one) do
        Person.new
      end

      let(:document_two) do
        Person.new
      end

      context "when the documents exist in the identity map" do

        before do
          identity_map.set(document_one)
          identity_map.set(document_two)
        end

        let(:get_multi) do
          identity_map.get_multi(
            Person.where(:_id.exists => true)
          )
        end

        it "returns the matching document" do
          get_multi.should eq([ document_one, document_two ])
        end
      end

      context "when the documents do not exist in the map" do

        let(:get_multi) do
          identity_map.get_multi(
            Person.where(:_id.exists => true)
          )
        end

        it "returns []" do
          get_multi.should be_empty
        end
      end
    end

    describe ".get_multi" do

      let(:document_one) do
        Person.new
      end

      let(:document_two) do
        Person.new
      end

      context "when the documents exist in the identity map" do

        before do
          described_class.set(document_one)
          described_class.set(document_two)
        end

        let(:get_multi) do
          described_class.get_multi(
            Person.where(:_id.exists => true)
          )
        end

        it "returns the matching document" do
          get_multi.should eq([ document_one, document_two ])
        end
      end

      context "when the documents do not exist in the map" do

        let(:get_multi) do
          described_class.get_multi(
            Person.where(:_id.exists => true)
          )
        end

        it "returns []" do
          get_multi.should be_empty
        end
      end
    end

    describe "#remove" do

      let(:document) do
        Person.new
      end

      before do
        identity_map.set(document)
      end

      context "when provided a document" do

        let!(:removed) do
          identity_map.remove(document)
        end

        it "removes the document from the map" do
          identity_map[Person].should be_empty
        end

        it "returns the document" do
          removed.should eq(document)
        end
      end

      context "when provided nil" do

        let!(:removed) do
          identity_map.remove(nil)
        end

        it "returns nil" do
          removed.should be_nil
        end
      end
    end

    describe "#set" do

      context "when setting a document" do

        let(:document) do
          Person.new
        end

        let!(:set) do
          identity_map.set(document)
        end

        let(:get) do
          identity_map.get(Person.where(:_id => document.id))
        end

        it "puts the object in the identity map" do
          get.should eq(document)
        end
      end

      context "when setting nil" do

        let!(:set) do
          identity_map.set(nil)
        end

        it "places nothing in the map" do
          identity_map.should be_empty
        end

        it "returns nil" do
          set.should be_nil
        end
      end
    end

    describe ".set" do

      context "when setting a document" do

        let(:document) do
          Person.new
        end

        let!(:set) do
          described_class.set(document)
        end

        let(:get) do
          described_class.get(Person.where(:_id => document.id))
        end

        it "puts the object in the identity map" do
          get.should eq(document)
        end
      end

      context "when setting nil" do

        let!(:set) do
          described_class.set(nil)
        end

        it "returns nil" do
          set.should be_nil
        end
      end
    end
  end

  context "when executing in a fiber" do

    if RUBY_VERSION.to_f >= 1.9

      describe "#.get" do

        let(:document) do
          Person.new
        end

        let(:criteria) do
          Person.where(:_id => document.id)
        end

        let(:fiber) do
          Fiber.new do
            described_class.set(document)
            described_class.get(criteria).should eq(document)
          end
        end

        it "gets the object from the identity map" do
          fiber.resume
        end
      end
    end
  end
end
