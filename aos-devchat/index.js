const { Client, GatewayIntentBits } = require('discord.js');
const settings = require('./config');

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

client.once('ready', () => {
  console.log(`BOT NAME : ${client.user.tag}!`);
  console.log(`You can now send messages via AOS-Chat bot`);
});

client.on('messageCreate', async message => {
  if (message.channel.id === settings.channelId && !message.author.bot) {
    try {
      await sendMessage(message);
    } catch (error) {
      console.error('sendMessage error', error?.response?.data || error);
      return;
    }
  }
});

client.login(process.env.DISCORD_TOKEN);

process.on('uncaughtException', function (err) {
  console.error('uncaughtException', err);
});

global.channelId = settings.channelId;

const express = require('express');
const { sendMessage } = require('./fetch/message.js');

const app = express();
const port = 3000;

app.use(express.json());

app.get('/send_message', (req, res) => {
  const messageContent = req.query.message;

  if (messageContent) {
    const channel = client.channels.cache.get(settings.channelId);
    if (channel) {
      channel.send(messageContent)
        .then(() => {
          res.status(200).send('Message sent successfully!');
        })
        .catch(err => {
          console.error(err);
          res.status(500).send('Failed to send message.');
        });
    } else {
      res.status(404).send('Channel not found.');
    }
  } else {
    res.status(400).send('No message content provided.');
  }
});

app.listen(port, () => {
  console.log(`PORT: ${port}`);
});

const { Worker } = require('worker_threads');

const worker = new Worker('./fetch/bot.js');

worker.on('message', message => {
  const channel = client.channels.cache.get(settings.channelId);
  if (channel) {
    channel.send(message)
      .then(() => {
        console.log('Message sent successfully!');
      })
      .catch(err => {
        console.error(err);
        console.log('Failed to send message.');
      });
  } else {
    console.log('Channel not found.');
  }
});
