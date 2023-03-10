
require 'dish'
require 'menu'
require 'cart'

describe "integration" do
  before(:each) do
    @terminal = double(:terminal)
    @fake_requester = double(:requester)
    @twilio_requester = double(:twilio_requester)
    @account_sid = '123456789'
    @auth_token = '987654321'
    @fake_number = '+446222949749'

    @menu = Menu.new(@terminal)
    @dish1 = Dish.new("chicken rice", 20)
    @dish2 = Dish.new("char siew pao", 3)
    @menu.add_to_selection(@dish1)
    @menu.add_to_selection(@dish2)
    @cart = Cart.new(@terminal, @fake_requester, @twilio_requester, @account_sid, @auth_token, @fake_number)
  end
  
  it "adds 2 dishes to menu and displays the menu selection" do
    expect(@terminal).to receive(:puts).with("Our food selection:")
    expect(@terminal).to receive(:puts).with("1. Chicken Rice - RM20")
    expect(@terminal).to receive(:puts).with("2. Char Siew Pao - RM3")
    @menu.view_selection
  end

    it "adds a dish that is not on the menu, returns a message telling the user that this dish doesn't exist" do
    dish3 = Dish.new("siew mai", 2)
    expect(@terminal).to receive(:puts).with("This dish is not on the menu.")
    @cart.add_to_cart(dish3,@menu)
  end

  it "adds 2 dishes from the menu to the cart and displays the cart" do
    @cart.add_to_cart(@dish1,@menu)
    @cart.add_to_cart(@dish2,@menu)
    expect(@terminal).to receive(:puts).with("Your cart:")
    expect(@terminal).to receive(:puts).with("1. Chicken Rice - RM20")
    expect(@terminal).to receive(:puts).with("2. Char Siew Pao - RM3")
    expect(@terminal).to receive(:puts).with("Total: RM23")
    @cart.view_cart
  end

  it "adds 2 dishes from the menu to the cart and orders the food, prints a message informing the user of the delivery time" do
    allow(@fake_requester).to receive(:get).with(
      URI('https://worldtimeapi.org/api/ip')
      ).and_return('{"abbreviation":"GMT","client_ip":"82.163.117.26","datetime":"2023-01-25T13:51:43.297669+00:00","day_of_week":3,"day_of_year":25,"dst":false,"dst_from":null,"dst_offset":0,"dst_until":null,"raw_offset":0,"timezone":"Europe/London","unixtime":1674654703,"utc_datetime":"2023-01-25T13:51:43.297669+00:00","utc_offset":"+00:00","week_number":4}')
    
    expect(@twilio_requester).to receive(:new).with(@account_sid, @auth_token).and_return(@twilio_requester)
    expect(@twilio_requester).to receive(:messages).and_return(@twilio_requester)
    expect(@twilio_requester).to receive(:create).with(
      body: "Thank you! Your order was placed and will be delivered before 14:31.",  
      messaging_service_sid: 'MG58ce52ba6f5a86cffcdd80b38fadef53',      
      to: @fake_number,
    ).and_return("Thank you! Your order was placed and will be delivered before 14:31.")

    cart = Cart.new(@terminal, @fake_requester, @twilio_requester, @account_sid, @auth_token, @fake_number)
    cart.add_to_cart(@dish1,@menu)
    cart.add_to_cart(@dish2,@menu)
    expect(cart.order).to eq "Thank you! Your order was placed and will be delivered before 14:31."
  end

  it "adds 2 dishes from the menu to the cart and orders the food, prints a message informing the user of the delivery time" do
    allow(@fake_requester).to receive(:get).with(
      URI('https://worldtimeapi.org/api/ip')
      ).and_return('{"abbreviation":"GMT","client_ip":"82.163.117.26","datetime":"2023-01-25T14:49:59.694555+00:00","day_of_week":3,"day_of_year":25,"dst":false,"dst_from":null,"dst_offset":0,"dst_until":null,"raw_offset":0,"timezone":"Europe/London","unixtime":1674658199,"utc_datetime":"2023-01-25T14:49:59.694555+00:00","utc_offset":"+00:00","week_number":4}')
    
    expect(@twilio_requester).to receive(:new).with(@account_sid, @auth_token).and_return(@twilio_requester)
    expect(@twilio_requester).to receive(:messages).and_return(@twilio_requester)
    expect(@twilio_requester).to receive(:create).with(
      body: "Thank you! Your order was placed and will be delivered before 15:29.",  
      messaging_service_sid: 'MG58ce52ba6f5a86cffcdd80b38fadef53',      
      to: @fake_number,
    ).and_return("Thank you! Your order was placed and will be delivered before 15:29.")

    cart = Cart.new(@terminal, @fake_requester, @twilio_requester, @account_sid, @auth_token, @fake_number)
    cart.add_to_cart(@dish1,@menu)
    cart.add_to_cart(@dish2,@menu)
    expect(cart.order).to eq "Thank you! Your order was placed and will be delivered before 15:29."
  end

end