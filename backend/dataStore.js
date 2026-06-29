const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, 'db.json');

function readData() {
  try {
    const raw = fs.readFileSync(DB_PATH, 'utf8');
    return JSON.parse(raw);
  } catch (error) {
    console.error('Failed to read db.json:', error);
    return { users: [], clubs: [], events: [], historicalEvents: [], registrations: [] };
  }
}

function writeData(data) {
  try {
    fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (error) {
    console.error('Failed to write db.json:', error);
    return false;
  }
}

module.exports = {
  readData,
  writeData
};
