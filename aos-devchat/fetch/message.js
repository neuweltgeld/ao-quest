const { message, createDataItemSigner } = require('@permaweb/aoconnect');
const { readFileSync } = require('fs');
const settings = require('../config');

const wallet = JSON.parse(readFileSync('/root/.aos.json').toString());

async function sendMessage(msg) {
  const username = msg.author.username;

  await message({
    process: settings.processId,
    tags: [
      { name: 'Action', value: 'BroadcastDiscord' },
      { name: 'Data', value: msg.content },
      { name: 'Event', value: username },
    ],
    signer: createDataItemSigner(wallet),
    data: msg.content,
  })
  .then(console.log)
  .catch(console.error);
}

module.exports = {
  sendMessage,
};
