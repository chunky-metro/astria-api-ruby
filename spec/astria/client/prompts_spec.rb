# frozen_string_literal: true

require 'spec_helper'

describe Astria::Client, ".prompts" do

  subject { described_class.new(base_url: "https://api.astria.test", access_token: "a1b2c3").prompts }


  describe "#list_prompts" do
    let(:account_id) { 1010 }

    before do
      stub_request(:get, %r{/v2/#{account_id}/prompts})
          .to_return(read_http_fixture("listPrompts/success.http"))
    end

    it "builds the correct request" do
      subject.list_prompts(account_id)

      expect(WebMock).to have_requested(:get, "https://api.astria.test/v2/#{account_id}/prompts")
          .with(headers: { "Accept" => "application/json" })
    end

    it "supports pagination" do
      subject.prompts(account_id, page: 2)

      expect(WebMock).to have_requested(:get, "https://api.astria.test/v2/#{account_id}/prompts?page=2")
    end

    it "supports extra request options" do
      subject.prompts(account_id, query: { foo: "bar" })

      expect(WebMock).to have_requested(:get, "https://api.astria.test/v2/#{account_id}/prompts?foo=bar")
    end

    it "supports sorting" do
      subject.prompts(account_id, sort: "short_name:desc")

      expect(WebMock).to have_requested(:get, "https://api.astria.test/v2/#{account_id}/prompts?sort=short_name:desc")
    end

    it "returns the list of prompts" do
      response = subject.list_prompts(account_id)
      expect(response).to be_a(Astria::CollectionResponse)

      response.data.each do |result|
        expect(result).to be_a(Astria::Struct::Prompt)
        expect(result.id).to be_a(Numeric)
        expect(result.account_id).to be_a(Numeric)
        expect(result.name).to be_a(String)
        expect(result.sid).to be_a(String)
        expect(result.description).to be_a(String)
      end
    end
  end

  describe "#all_prompts" do
    before do
      stub_request(:get, %r{/v2/#{account_id}/prompts})
          .to_return(read_http_fixture("listPrompts/success.http"))
    end

    let(:account_id) { 1010 }

    it "delegates to client.paginate" do
      expect(subject).to receive(:paginate).with(:prompts, account_id, { foo: "bar" })
      subject.all_prompts(account_id, { foo: "bar" })
    end

    it "supports sorting" do
      subject.all_prompts(account_id, sort: "short_name:desc")

      expect(WebMock).to have_requested(:get, "https://api.astria.test/v2/#{account_id}/prompts?page=1&per_page=100&sort=short_name:desc")
    end
  end

  describe "#create_prompt" do
    let(:account_id) { 1010 }
    let(:attributes) { { name: "Beta", short_name: "beta", description: "A beta prompt." } }

    before do
      stub_request(:post, %r{/v2/#{account_id}/prompts$})
          .to_return(read_http_fixture("createPrompt/created.http"))
    end


    it "builds the correct request" do
      subject.create_prompt(account_id, attributes)

      expect(WebMock).to have_requested(:post, "https://api.astria.test/v2/#{account_id}/prompts")
          .with(headers: { "Accept" => "application/json" })
    end

    it "returns the list of prompts" do
      response = subject.create_prompt(account_id, attributes)
      expect(response).to be_a(Astria::Response)

      prompt = response.data
      expect(prompt).to be_a(Astria::Struct::Prompt)
      expect(prompt.id).to eq(1)
      expect(prompt.account_id).to eq(1010)
      expect(prompt.name).to eq("Beta")
      expect(prompt.sid).to eq("beta")
      expect(prompt.description).to eq("A beta prompt.")
    end
  end

  describe "#prompt" do
    let(:account_id) { 1010 }
    let(:prompt_id) { 1 }

    before do
      stub_request(:get, %r{/v2/#{account_id}/prompts/#{prompt_id}$})
          .to_return(read_http_fixture("getPrompt/success.http"))
    end

    it "builds the correct request" do
      subject.prompt(account_id, prompt_id)

      expect(WebMock).to have_requested(:get, "https://api.astria.test/v2/#{account_id}/prompts/#{prompt_id}")
          .with(headers: { "Accept" => "application/json" })
    end

    it "returns the list of prompts" do
      response = subject.prompt(account_id, prompt_id)
      expect(response).to be_a(Astria::Response)

      prompt = response.data
      expect(prompt).to be_a(Astria::Struct::Prompt)
      expect(prompt.id).to eq(1)
      expect(prompt.account_id).to eq(1010)
      expect(prompt.name).to eq("Alpha")
      expect(prompt.sid).to eq("alpha")
      expect(prompt.description).to eq("An alpha prompt.")
    end
  end

  describe "#update_prompt" do
    let(:account_id) { 1010 }
    let(:attributes) { { name: "Alpha", short_name: "alpha", description: "An alpha prompt." } }
    let(:prompt_id) { 1 }

    before do
      stub_request(:patch, %r{/v2/#{account_id}/prompts/#{prompt_id}$})
          .to_return(read_http_fixture("updatePrompt/success.http"))
    end


    it "builds the correct request" do
      subject.update_prompt(account_id, prompt_id, attributes)

      expect(WebMock).to have_requested(:patch, "https://api.astria.test/v2/#{account_id}/prompts/#{prompt_id}")
          .with(headers: { "Accept" => "application/json" })
    end

    it "returns the list of prompts" do
      response = subject.update_prompt(account_id, prompt_id, attributes)
      expect(response).to be_a(Astria::Response)

      prompt = response.data
      expect(prompt).to be_a(Astria::Struct::Prompt)
      expect(prompt.id).to eq(1)
      expect(prompt.account_id).to eq(1010)
      expect(prompt.name).to eq("Alpha")
      expect(prompt.sid).to eq("alpha")
      expect(prompt.description).to eq("An alpha prompt.")
    end
  end

  describe "#delete_prompt" do
    let(:account_id) { 1010 }
    let(:prompt_id) { 5410 }

    before do
      stub_request(:delete, %r{/v2/#{account_id}/prompts/#{prompt_id}$})
          .to_return(read_http_fixture("deletePrompt/success.http"))
    end

    it "builds the correct request" do
      subject.delete_prompt(account_id, prompt_id)

      expect(WebMock).to have_requested(:delete, "https://api.astria.test/v2/#{account_id}/prompts/#{prompt_id}")
          .with(headers: { "Accept" => "application/json" })
    end

    it "returns nil" do
      response = subject.delete_prompt(account_id, prompt_id)
      expect(response).to be_a(Astria::Response)
      expect(response.data).to be_nil
    end
  end

  describe "#apply_prompt" do
    let(:account_id)  { 1010 }
    let(:prompt_id) { 5410 }
    let(:domain_id)   { 'example.com' }

    before do
      stub_request(:post, %r{/v2/#{account_id}/domains/#{domain_id}/prompts/#{prompt_id}$})
          .to_return(read_http_fixture("applyPrompt/success.http"))
    end

    it "builds the correct request" do
      subject.apply_prompt(account_id, prompt_id, domain_id)

      expect(WebMock).to have_requested(:post, "https://api.astria.test/v2/#{account_id}/domains/#{domain_id}/prompts/#{prompt_id}")
          .with(headers: { "Accept" => "application/json" })
    end

    it "returns nil" do
      response = subject.apply_prompt(account_id, prompt_id, domain_id)
      expect(response).to be_a(Astria::Response)
      expect(response.data).to be_nil
    end
  end

end
