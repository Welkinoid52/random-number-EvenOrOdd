//Node.js app that takes a number (e.g., from the first app) as a query parameter and tells whether it's even or odd.


const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  const randomNumber = Math.floor(Math.random() * 100); // Random number between 0–999
  res.send(`Random Number: ${randomNumber}`);
});

app.listen(port, () => {
  console.log(`App is running at http://index:${port}`);
});


