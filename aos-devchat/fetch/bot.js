const { results } = require('@permaweb/aoconnect');
const { parentPort } = require('worker_threads');
const settings = require('../config');

let cursor = '';

async function fetching() {
  try {
    if (cursor === '') {
      const resultsOut = await results({
        process: settings.processId,
        sort: 'DESC',
        limit: 1,
      });
      cursor = resultsOut.edges[0].cursor;
    }

    console.log('Fetching...');
    const resultsOut2 = await results({
      process: settings.processId,
      from: cursor,
      sort: 'ASC',
      limit: 50,
    });

    for (const element of resultsOut2.edges.reverse()) {
      cursor = element.cursor;
      if (element.node.Messages.length === 0) {
        continue;
      }
      const messagesData = element.node.Messages.filter(
        e => e.Target === settings.processId && e.Tags.some(f => f.name === 'Action' && f.value === 'SendDiscordMsg')
      );
      for (const messagesItem of messagesData) {
        const event = messagesItem.Tags.find(e => e.name === 'Event')?.value;
        const sendTest = `${event} : ${messagesItem.Data}`;
        parentPort.postMessage(sendTest);
      }
    }
  } catch (error) {
    console.error('Fetching error:', error);
  } finally {
    setTimeout(fetching, 5000);
  }
}

fetching();
