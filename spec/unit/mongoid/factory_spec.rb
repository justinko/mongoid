require "spec_helper"

describe Mongoid::Factory do

  describe ".build" do

    let(:person) do
      described_class.build(Person, attributes)
    end

    context "when the _type attribute is present" do

      context "when the type is a superclass" do

        let(:attributes) do
          { "_type" => "Person", "title" => "Sir" }
        end

        it "instantiates the correct class" do
          person.should be_a(Person)
        end

        it "sets the attributes" do
          person.title.should eq("Sir")
        end
      end

      context "when the type is a subclass" do

        let(:attributes) do
          { "_type" => "Doctor", "title" => "Sir" }
        end

        it "instantiates the correct class" do
          person.should be_a(Doctor)
        end

        it "sets the attributes" do
          person.title.should eq("Sir")
        end
      end

      context "when the type is not in the hierarchy" do

        let(:attributes) do
          { "_type" => "Canvas", "title" => "Sir" }
        end

        it "instantiates the default type" do
          person.should be_a(Person)
        end
      end
    end

    context "when _type is not preset" do

      let(:attributes) do
        { "title" => "Sir" }
      end

      it "instantiates based on the default" do
        person.should be_a(Person)
      end

      it "sets the attributes" do
        person.title.should eq("Sir")
      end
    end

    context "when _type is an empty string" do

      let(:attributes) do
        { "title" => "Sir", "_type" => "" }
      end

      it "instantiates based on the default" do
        person.should be_a(Person)
      end

      it "sets the attributes" do
        person.title.should eq("Sir")
      end
    end
  end

  describe ".from_db" do

    context "when a type is in the attributes" do

      context "when the type is a class" do

        let(:attributes) do
          { "_type" => "Person", "title" => "Sir" }
        end

        let(:document) do
          described_class.from_db(Address, attributes)
        end

        it "generates based on the type" do
          document.should be_a(Person)
        end

        it "sets the attributes" do
          document.title.should eq("Sir")
        end

        it "puts the document in the identity map" do
          Mongoid::IdentityMap.get(document.id).should eq(document)
        end
      end

      context "when the type is empty" do

        let(:attributes) do
          { "_type" => "", "title" => "Sir" }
        end

        let(:document) do
          described_class.from_db(Person, attributes)
        end

        it "generates based on the provided class" do
          document.should be_a(Person)
        end

        it "sets the attributes" do
          document.title.should eq("Sir")
        end

        it "puts the document in the identity map" do
          Mongoid::IdentityMap.get(document.id).should eq(document)
        end
      end
    end

    context "when a type is not in the attributes" do

      let(:attributes) do
        { "title" => "Sir" }
      end

      let(:document) do
        described_class.from_db(Person, attributes)
      end

      it "generates based on the provided class" do
        document.should be_a(Person)
      end

      it "sets the attributes" do
        document.title.should eq("Sir")
      end

      it "puts the document in the identity map" do
        Mongoid::IdentityMap.get(document.id).should eq(document)
      end
    end
  end
end
