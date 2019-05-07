class CreateApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :api_tokens do |t|
      t.string :base_url
      t.string :name
      t.string :username
      t.string :password
      t.string :client_id
      t.string :client_secret
      t.string :grant_type
      t.string :content_type
      t.string :token

      t.timestamps
    end


    ApiToken.new({
      name: "gstin_masters_india",
      base_url: 'https://commonapi.mastersindia.co',
      content_type: "application/json",
      username: "veekshith.rai@finly.io",
      password: "Veek@123#",
      client_id: "pwvTXWlwizCcfzUYzq",
      client_secret: "TkKJ8ZVYFHvVtutBfSxizimc",
      grant_type: "password",
      token: "6628ed73edc01bc23c2f599bae834360e25893ef"
    }).save

  end
end
