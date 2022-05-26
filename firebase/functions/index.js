const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotification = functions.https.onCall((data, context) => {
    const payload = {
        token: data.recipient_fcm_token,
        notification: {
            title: 'eeloo',
            body: data.sender_username + ' ti ha inviato un messaggio',
        },
        data: {
            body: '',
        }
    };

    admin.messaging().send(payload).then((response) => {
        // Response is a message ID string.
        console.log('Successfully sent notification: ', response);
        return { success: true };
    }).catch((error) => {
        console.log('Error sending notification: ', error);
        return { error: error.code };
    });
});
