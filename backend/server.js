const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

let users = [];

// Add User
app.post("/users", (req, res) => {
  users.push(req.body);

  res.json({
    success: true,
    message: "User Added",
  });
});

// Get Users
app.get("/users", (req, res) => {
  res.json(users);
});
20222
// Delete User
app.delete("/users/:index", (req, res) => {
  const index = parseInt(req.params.index);

  users.splice(index, 1);

  res.json({
    success: true,
    message: "User Deleted",
  });
});

app.listen(5000, () => {
  console.log("Server Running on Port 5000");
});