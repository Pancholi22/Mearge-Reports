const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const app = express();
const uploadDir = "D:/Scanned Files";

// Ensure the directory exists
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure Multer to save files in D:\Scanned Files
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname);
    }
});

const upload = multer({ storage: storage });

app.post("/upload", upload.single("file"), (req, res) => {
    res.send(`File saved to D:\\Scanned Files\\${req.file.originalname}`);
});

app.listen(5000, () => {
    console.log("Server running on http://localhost:5000");
});
