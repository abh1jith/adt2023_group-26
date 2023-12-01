const express = require("express");
const bodyParser = require("body-parser")
const mysql = require("mysql2");
const cors = require("cors");


const app = express();

app.use(cors());
app.use(bodyParser.json());

app.listen(3001, () => {
    console.log("Server started at port 3001")
});


const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'abhimani12',
    database: 'adt_project_2',
});

app.get('/getAllBooks', (req, res) => {
    db.execute("SELECT b.bookID, b.title, a.authorName, b.num_pages, b.publisher, r.average_rating, r.ratings_count FROM books b, ratings r, isbn i, authors a WHERE b.ratingID = r.ratingID AND i.bookID = b.bookID AND b.authorID = a.authorID;", (err, result) =>{
        if(err) console.log(err);
        res.send(result);
    })
});
