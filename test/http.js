const fetch = require("node-fetch");
const schedules = [
  {
    film: "1",
    room: "1",
    seats: 150,
    time: "11-20-2020",
  },
  {
    film: "2",
    room: "1",
    seats: 200,
    time: "12-22-2020",
  },
  {
    film: "1",
    room: "2",
    seats: 50,
    time: "12-20-2020",
  },
  {
    film: "3",
    room: "2",
    seats: 50,
    time: "1-20-2021",
  },
  {
    film: "3",
    room: "1",
    seats: 250,
    time: "2-12-2021",
  },
];

schedules.map((body) => {
  fetch("http://localhost:4000/schedules", {
    method: "POST", // or 'PUT'
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  })
    .then((response) => response.json())
    .then((data) => {
      console.log("Success:", data);
    })
    .catch((err) => console.log(err));
});

[...Array(5).keys()].map((e) =>
  fetch(`http://localhost:4000/schedules/${e}`, {
    method: "delete",
  })
    .then((response) => response.json())
    .then((data) => {
      console.log("Success:", data);
    })
    .catch((err) => console.log(err))
);
