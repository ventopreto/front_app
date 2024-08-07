import consumer from "./consumer"

consumer.subscriptions.create("ListOfPoliciesChannel", {
  connected() {
    console.log("Connected to the MessageChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data)
    const {id, payment_status} = data;
    const html = document.getElementById(id)
    html.querySelector("#payment_status").innerText = payment_status
    html.querySelector("#payment_link").innerText = ""
  }
});
