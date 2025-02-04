const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('../.ghost/admin.db');
const fs = require('fs');
const path = require('path');
const sendMail = require('./gmail');

const GHOST_DOMAIN = 'http://18.142.4.255:2368/ghost/#/signup/'

const main = async () => {

  db.serialize(() => {
    db.each("SELECT * FROM invites where status='pending'", async (err, row) => {
      console.log(err)
      console.log(row.id + ": " + row.email);

      console.log('sending invite to ', row.email)
      const TO = row.email
      const FROM = 'venkat@hashstack.finance'

      const options = {
        to: TO,
        // cc: '',
        replyTo: FROM,
        subject: 'Hashstack docs admin invite',
        text: `Please click below link to signup:\n\n ${GHOST_DOMAIN}${row.token}`,
        html: `Please click the link to signup: <a href="${GHOST_DOMAIN}${row.token}">link</a>`,
        textEncoding: 'base64',
        headers: [
          { key: 'X-Application-Version', value: 'v1.0.0.2' },
        ],
      };

      const messageId = await sendMail(options);


      return messageId;
    });
    // db.run(`UPDATE invites SET status='sent' where email='${row.email}'`);
  });
    
  db.close();

};

main()
  .then((messageId) => console.log('Message sent successfully:', messageId))
  .catch((err) => console.error(err));