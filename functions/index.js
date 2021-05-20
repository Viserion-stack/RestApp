
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.helloWord = functions
  .database.ref('/orders/{ordersId}').onUpdate((snapshot, context) => {

    const ordersId = context.params.ordersId;
  
    const orderData = snapshot.after.val();
    const creatorId = orderData.creatorId;
    const tableNumber = orderData.tableNumber;
    const token2 = orderData.token;
    
    //console.log('orderId = ',ordersId);
    //console.log('creatorId = ',creatorId);
    //console.log('tableNumber = ',tableNumber);
    console.log('token2 = ',token2);

    const payload = {
      notification: {

        title: 'Zamówienie dla stolika nr ' + tableNumber +' jest gotowe',
        body: 'Zamówienie jest gotowe',
        badge: '1',
        sound: 'default'
      }
    };
   


    return admin.database().ref('orders').once('value').then(allToken => {
      if (allToken.val()) {
        //console.log('token available');
        const token = Object.keys(allToken.val());
        console.log(token);
        return admin.messaging().sendToDevice(token2, payload);
      } else {
        
        return console.log('No avilable token');
        
      }

    }); 
  });
