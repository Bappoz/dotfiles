const {PrayTime} = require('./vendor/praytime.cjs');
const [lat,lon,method,zone] = process.argv.slice(2);
const latitude=Number(lat), longitude=Number(lon);
if (!Number.isFinite(latitude)||Math.abs(latitude)>90||!Number.isFinite(longitude)||Math.abs(longitude)>180) process.exit(1);
const calculator = new PrayTime(method || 'MWL');
calculator.location([latitude,longitude]).timezone(zone);
console.log(JSON.stringify(calculator.getTimes()));
