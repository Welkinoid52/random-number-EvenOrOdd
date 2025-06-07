const express = require('express');
const axios = require('axios');
const app = express();
const port = 4000;

// Helper to check if a number is prime
function isPrime(num) {
  if (num < 2) return false;
  for (let i = 2; i <= Math.sqrt(num); i++) {
    if (num % i === 0) return false;
  }
  return true;
}

app.get('/', async (req, res) => {
  try {
    // Use axios to fetch the number (since you imported axios)
    const response = await axios.get('http://random-num-gen:3000/');

    // response.data is the response body string
    const numberMatch = response.data.match(/\d+/);

    if (!numberMatch) {
      return res.status(500).send('<h1>Error extracting number from random-num-gen response</h1>');
    }

    const number = parseInt(numberMatch[0]);
    const isEven = number % 2 === 0;
    const prime = isPrime(number);

    const htmlResponse = `
      <html>
        <head>
          <title>Number Info</title>
          <meta http-equiv="refresh" content="10"> <!-- Auto-refresh every 10 seconds -->
          <style>
            body { font-family: Arial, sans-serif; padding: 20px; background:rgb(52, 64, 193); }
            .box { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); max-width: 400px; margin: auto; }
            h1 { color: #333; }
            p { font-size: 18px; }
            button {
              margin-top: 20px;
              padding: 10px 20px;
              font-size: 16px;
              border: none;
              border-radius: 6px;
              background-color:rgb(0, 255, 136);
              color: white;
              cursor: pointer;
            }
            button:hover {
              background-color: #0056b3;
            }
          </style>
        </head>
        <body>
          <div class="box">
            <h1>Number Analysis</h1>
            <p><strong>Random Number:</strong> ${number}</p>
            <p><strong>Type:</strong> ${isEven ? 'Even' : 'Odd'}</p>
            <p><strong>Prime:</strong> ${prime ? 'Yes' : 'No'}</p>
            <form method="GET" action="/">
              <button type="submit">Get New Number</button>
            </form>
            <p style="font-size: 14px; color: #777;">(Auto-refreshes every 10 seconds)</p>
          </div>
        </body>
      </html>
    `;

    res.send(htmlResponse);

  } catch (error) {
    console.error('Error calling random-num-gen:', error.message);
    res.status(500).send('<h1>Failed to fetch from random-num-gen service</h1>');
  }
});

app.listen(port, () => {
  console.log(`Client service is running at http://localhost:${port}`);
});
