class PlaidService
    require 'plaid'

    def create_client
        configuration = Plaid::Configuration.new
        configuration.server_index = Plaid::Configuration::Environment["sandbox"]
        configuration.api_key["PLAID-CLIENT-ID"] = "63977631cfa3bf0013f336d0"
        configuration.api_key["PLAID-SECRET"] = "eff68a433b4cab8638c1712cf534a7"

        api_client = Plaid::ApiClient.new(
            configuration
        )
        @client = Plaid::PlaidApi.new(api_client)
    end

    def create_item
        create_client
        request = Plaid::SandboxPublicTokenCreateRequest.new(
            {
              institution_id: 'ins_109508',
              initial_products: ["transactions"]
            }
          )
        response = @client.sandbox_public_token_create(request)
        # The generated public_token can now be
        # exchanged for an access_token
        publicToken = response.public_token
        item_public_token_exchange_request = Plaid::ItemPublicTokenExchangeRequest.new(
        {
            public_token: publicToken
        }
        )
        @public_response = @client.item_public_token_exchange(item_public_token_exchange_request)

        request = Plaid::ItemGetRequest.new({ access_token: @public_response.access_token })
        response = @client.item_get(request)
        item = response.item
        status = response.status
    end

    def get_account
        create_client
        create_item
        request = Plaid::AccountsGetRequest.new({ access_token: @public_response.access_token })
        response = @client.accounts_get(request)
        accounts = response.accounts
    end
end
  