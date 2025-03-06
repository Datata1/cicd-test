#!/bin/bash
npx express-generator --no-view simple-app
cd simple-app

# Install dependencies
npm install

# Server auf 0.0.0.0 und Port 3000 ändern
sed -i 's/3000, ()/3000, "0.0.0.0"/g' ./bin/www

# App starten
npm start
